import type {
  TerminalLogEvent as NativeTerminalLogEvent,
  ConnectEvent as NativeConnectEvent,
  ClosedEvent as NativeClosedEvent,
  OSCEvent as NativeOSCEvent,
  SizeChangedEvent as NativeSizeChangedEvent,
  HostCurrentDirectoryUpdateEvent as NativeHostCurrentDirectoryUpdateEvent,
  ScrollEvent as NativeScrollEvent,
  RequestOpenLinkEvent as NativeRequestOpenLinkEvent,
  BellEvent as NativeBellEvent,
  ClipboardCopyEvent as NativeClipboardCopyEvent,
  ITermContentEvent as NativeITermContentEvent,
  RangeChangedEvent as NativeRangeChangedEvent,
  DownloadCompleteEvent as NativeDownloadCompleteEvent,
  UploadCompleteEvent as NativeUploadCompleteEvent,
  DownloadProgressEvent as NativeDownloadProgressEvent,
  UploadProgressEvent as NativeUploadProgressEvent,
} from './RtnSshTerminalViewNativeComponent';

export interface TerminalLogEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeTerminalLogEvent;
}

export interface ConnectEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeConnectEvent;
}

export interface ClosedEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeClosedEvent;
}

export interface OSCEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeOSCEvent;
}

export interface SizeChangedEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeSizeChangedEvent;
}

export interface HostCurrentDirectoryUpdateEvent
  extends React.BaseSyntheticEvent {
  nativeEvent: NativeHostCurrentDirectoryUpdateEvent;
}

export interface ScrollEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeScrollEvent;
}

export interface RequestOpenLinkEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeRequestOpenLinkEvent;
}

export interface BellEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeBellEvent;
}

export interface ClipboardCopyEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeClipboardCopyEvent;
}

export interface ITermContentEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeITermContentEvent;
}

export interface RangeChangedEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeRangeChangedEvent;
}

export interface DownloadCompleteEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeDownloadCompleteEvent;
}

export interface UploadCompleteEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeUploadCompleteEvent;
}

export interface DownloadProgressEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeDownloadProgressEvent;
}

export interface UploadProgressEvent extends React.BaseSyntheticEvent {
  nativeEvent: NativeUploadProgressEvent;
}

export interface SshTerminalMethods {
  connect: () => void;
  close: () => void;
  writeCommand: (command: string) => void;
  download: (callbackId: string, from: string, to: string) => void;
  upload: (callbackId: string, from: string, to: string) => void;
  sendMotionWithButtonFlags: (
    buttonFlags: number,
    x: number,
    y: number,
    pixelX: number,
    pixelY: number
  ) => void;
  encodeButtonWithButton: (
    button: number,
    release: boolean,
    shift: boolean,
    meta: boolean,
    control: boolean
  ) => Promise<number>;
  sendEventWithButtonFlags: (buttonFlags: number, x: number, y: number) => void;
  sendEventWithButtonFlagsPixel: (
    buttonFlags: number,
    x: number,
    y: number,
    pixelX: number,
    pixelY: number
  ) => void;
  // feedBuffer: (buffer: ArrayBuffer) => void;
  feedText: (text: string) => void;
  // feedByteArray: (byteArray: ArrayBuffer) => void;
  // getText: () => Promise<string>;
  // sendResponse: (items: ArrayBuffer) => void;
  sendResponseText: (text: string) => void;
  changedLines: () => Promise<Set<number>>;
  clearUpdateRange: () => void;
  emitLineFeed: () => void;
  garbageCollectPayload: () => void;
  // getBufferAsData: () => Promise<ArrayBuffer>;
  // getCharData: () => Promise<any>;
  // getCharacter: () => Promise<string>;
  // getCursorLocation: () => Promise<{x: number, y: number}>;
  // getDims: () => Promise<{cols: number, rows: number}>;
  // getLine: (lineIndex: number) => Promise<string>;
  // getScrollInvariantLine: (lineIndex: number) => Promise<string>;
  // getScrollInvariantUpdateRange: () => Promise<any>;
  getTopVisibleRow: () => Promise<number>;
  // getUpdateRange: () => Promise<any>;
  hideCursor: () => void;
  showCursor: () => void;
  installColors: (colors: string) => void;
  refresh: (startRow: number, endRow: number) => void;
  // registerOscHandler: (command: number, callback: (data: string) => void) => void;
  resetToInitialState: () => void;
  resize: (cols: number, rows: number) => void;
  scroll: () => void;
  // setCursorStyle: (style: string) => void;
  setIconTitle: (text: string) => void;
  setTitle: (text: string) => void;
  softReset: () => void;
  updateFullScreen: () => void;
}
