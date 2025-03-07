import NewMessageLocation from "./NewMessageLocation";

interface NewMessageSpan {
    end: NewMessageLocation;
    file: string;
    start: NewMessageLocation;
}

export default NewMessageSpan;
