declare module 'react-native-config' {
  export interface NativeConfig {
    SSH_HOST: string;
    SSH_PORT: number;
    SSH_USER: string;
    SSH_PASS: string;
  }

  export const Config: NativeConfig;
  export default Config;
}
