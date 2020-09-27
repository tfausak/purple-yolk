'use strict';

const lsp = require('vscode-languageclient');
const path = require('path');
const purpleYolk = require('../package.json');
const vscode = require('vscode');

const serverOptions = (context) => {
  const server = context.asAbsolutePath(path.join('dist', 'server.js'));
  return {
    debug: {
      module: server,
      options: { execArgv: ['--inspect=6009', '--nolazy'] },
      transport: lsp.TransportKind.ipc,
    },
    run: { module: server, transport: lsp.TransportKind.ipc },
  };
};

const clientOptions = (outputChannel) => ({
  documentSelector: [{ language: 'haskell', scheme: 'file' }],
  outputChannel,
});

const onRestartCommand = (client) =>
  client.sendNotification(`${purpleYolk.name}/restartGhci`, null);

const onShowOutputCommand = (outputChannel) => outputChannel.show(true);

const onUpdateStatusBarItemNotification = (statusBarItem, text) => {
  statusBarItem.text = text;
};

module.exports = {
  activate: (context) => {
    const outputChannel = vscode.window
      .createOutputChannel(purpleYolk.displayName);

    const client = new lsp.LanguageClient(
      purpleYolk.displayName,
      serverOptions(context),
      clientOptions(outputChannel)
    );

    client.start();

    context.subscriptions.push(vscode.commands.registerCommand(
      `${purpleYolk.name}.restart`,
      () => onRestartCommand(client)
    ));

    context.subscriptions.push(vscode.commands.registerCommand(
      `${purpleYolk.name}.showOutput`,
      () => onShowOutputCommand(outputChannel)
    ));

    const statusBarItem = vscode.window.createStatusBarItem();
    statusBarItem.command = `${purpleYolk.name}.showOutput`;
    statusBarItem.text = `${purpleYolk.displayName}: Initializing`;
    statusBarItem.show();

    client.onReady().then(() => {
      vscode.window.withProgress({
        location: vscode.ProgressLocation.Notification,
        title: purpleYolk.displayName,
      }, (progress) => {
        client.onNotification(
          `${purpleYolk.name}/updateStatusBarItem`,
          (text) => onUpdateStatusBarItemNotification(statusBarItem, text)
        );

        client.onNotification(
          `${purpleYolk.name}/updateProgress`,
          (text) => progress.report({ message: text })
        );

        return new Promise(() => {});
      });
    });
  },
};
