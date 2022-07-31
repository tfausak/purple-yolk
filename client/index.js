'use strict';

const lsp = require('vscode-languageclient');
const path = require('path');
const py = require('../package.json');
const vscode = require('vscode');

const progresses = {};

const activate = (context) => {
  const outputChannel = vscode.window.createOutputChannel(py.displayName);

  const client = new lsp.LanguageClient(
    py.displayName,
    {
      run: {
        module: context.asAbsolutePath(path.join('dist', 'server.js')),
        transport: lsp.TransportKind.ipc,
      },
    },
    {
      documentSelector: [{ language: 'haskell', scheme: 'file' }],
      outputChannel,
    }
  );

  context.subscriptions.push(vscode.commands.registerCommand(
    `${py.name}.lintFile`,
    () => {
      const editor = vscode.window.activeTextEditor;
      if (editor) {
        client.sendNotification(
          `${py.name}/lintFile`,
          editor.document.fileName
        );
      }
    }
  ));

  context.subscriptions.push(vscode.commands.registerCommand(
    `${py.name}.restart`,
    () => client.sendNotification(`${py.name}/restart`, null)
  ));

  context.subscriptions.push(vscode.commands.registerCommand(
    `${py.name}.showOutput`,
    () => outputChannel.show(true)
  ));

  const statusBarItem = vscode.window.createStatusBarItem();
  statusBarItem.command = `${py.name}.showOutput`;
  statusBarItem.text = py.displayName;
  statusBarItem.tooltip = 'Click to show output.';
  statusBarItem.show();

  client.start().then(() => {
    client.onNotification(`${py.name}/showProgress`, ({ key, title }) => {
      const timeout = setTimeout(() =>
        vscode.window.withProgress({
          location: vscode.ProgressLocation.Notification,
          title: `${py.displayName}: ${title}`,
        }, (progress) => {
          progresses[key].progress = progress;
          return new Promise((resolve) => {
            progresses[key].resolve = resolve;
          });
        }), 1000);
      progresses[key] = { percent: 0, progress: null, resolve: null, timeout };
    });

    client.onNotification(
      `${py.name}/updateProgress`,
      ({ key, message, percent }) => {
        const progress = progresses[key];
        if (progress && progress.progress) {
          const increment = 100 * (percent - progress.percent);
          progress.percent = percent;
          progress.progress.report({ increment, message });
        }
      }
    );

    client.onNotification(`${py.name}/hideProgress`, ({ key }) => {
      const progress = progresses[key];
      if (progress) {
        if (progress.timeout) {
          clearTimeout(progress.timeout);
        }
        if (progress.resolve) {
          progress.resolve();
        }
        delete progresses[key];
      }
    });
  });
};

module.exports = { activate };
