export interface SshTerminalMethods {
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
  resizeTerminal: (cols: number, rows: number) => void;
  scroll: () => void;
  // setCursorStyle: (style: string) => void;
  setIconTitle: (text: string) => void;
  setTitle: (text: string) => void;
  softReset: () => void;
  updateFullScreen: () => void;
}
