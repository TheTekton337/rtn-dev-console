// import React, { useEffect, useState, type FC } from 'react';
// import {
//   Modal,
//   View,
//   Text,
//   StyleSheet,
//   TouchableOpacity,
//   FlatList,
// } from 'react-native';

// import {
//   asyncEventsObservable,
//   registerAsyncCallback,
// } from '../../observables/RTNEventService';
// import {
//   getVisibilityState,
//   registerModal,
//   toggleModal,
// } from '../../observables/ModalStateService';
// import type {
//   AsyncEvent,
//   DownloadProgressEvent,
//   TransferProgressEvent,
// } from '../../types/TerminalEvents';
// import { useTerminal } from '../../hooks/useTerminal';

// // import {
// //   registerModal,
// //   toggleModal,
// //   getVisibilityState,
// // } from '../services/ModalStateService';
// // import type {
// //   AsyncEvent,
// //   FileTransferEventData,
// // } from '../types/async_callbacks';

// interface TransferItem {
//   id: string;
//   type: 'upload' | 'download';
//   fileName: string;
//   progress: number;
// }

// interface ScpTransferLogsProps {
//   sessionId: string;
// }

// // TODO: This will need to filter the logdataservice perhaps (for convenience)
// const ScpTransferLogs: FC<ScpTransferLogsProps> = ({ sessionId }) => {
//   const { terminalId } = useTerminal();
//   const [modalId] = useState(`scp-transfer-logs-${sessionId}`);
//   const [isVisible, setIsVisible] = useState(false);
//   const [transfers, setTransfers] = useState<TransferItem[]>([]);

//   useEffect(() => {
//     registerModal(modalId);
//     const visibilitySubscription =
//       getVisibilityState(modalId).subscribe(setIsVisible);

//     /*
//       export interface DownloadProgressEvent {
//   terminalId: TerminalId;
//   callbackId: CallbackId;
//   bytesTransferred: number;
//   totalBytes: number;
// }
//       */
//     registerAsyncCallback('downloadProgress', (_event) => {});
//     const transferSubscription = asyncEventsObservable.subscribe(
//       (event: AsyncEvent<TransferProgressEvent>) => {
//         if (
//           event.type === 'fileTransferProgress' ||
//           event.type === 'fileTransferComplete'
//         ) {
//           setTransfers((prevTransfers) => {
//             const index = prevTransfers.findIndex(
//               (t) => t.id === event.callbackId
//             );
//             const newTransfer: TransferItem = {
//               id: event.callbackId,
//               type: event.data.type,
//               fileName: event.data.fileName,
//               progress:
//                 event.type === 'fileTransferComplete'
//                   ? 100
//                   : event.data.progress,
//             };
//             if (index === -1) {
//               return [...prevTransfers, newTransfer];
//             } else {
//               const updatedTransfers = [...prevTransfers];
//               updatedTransfers[index] = newTransfer;
//               return updatedTransfers;
//             }
//           });
//         }
//       }
//     );

//     return () => {
//       visibilitySubscription.unsubscribe();
//       transferSubscription.unsubscribe();
//     };
//   }, [modalId, terminalId]);

//   const renderItem = ({ item }: { item: TransferItem }) => (
//     <Text
//       style={styles.transferText}
//     >{`${item.type}: ${item.fileName} - ${item.progress}%`}</Text>
//   );

//   const onClosePressed = () => {
//     toggleModal(terminalId);
//   };

//   return (
//     <Modal
//       animationType="slide"
//       transparent={true}
//       visible={isVisible}
//       onRequestClose={onClosePressed}
//     >
//       <View style={styles.centeredView}>
//         <View style={styles.modalView}>
//           <FlatList
//             data={transfers}
//             renderItem={renderItem}
//             keyExtractor={(item) => item.id}
//             contentContainerStyle={styles.transfersContainer}
//           />
//           <TouchableOpacity style={styles.button} onPress={onClosePressed}>
//             <Text style={styles.buttonText}>Close</Text>
//           </TouchableOpacity>
//         </View>
//       </View>
//     </Modal>
//   );
// };

// const styles = StyleSheet.create({
//   centeredView: {
//     flex: 1,
//     justifyContent: 'center',
//     alignItems: 'center',
//     backgroundColor: 'rgba(0, 0, 0, 0.5)',
//   },
//   modalView: {
//     width: '90%',
//     minHeight: '80%',
//     backgroundColor: 'white',
//     borderRadius: 20,
//     padding: 20,
//     alignItems: 'center',
//     shadowColor: '#000',
//     shadowOffset: {
//       width: 0,
//       height: 2,
//     },
//     shadowOpacity: 0.25,
//     shadowRadius: 4.84,
//     elevation: 5,
//     overflow: 'hidden',
//   },
//   transfersContainer: {
//     width: '100%',
//   },
//   transferText: {
//     marginBottom: 10,
//     textAlign: 'left',
//     color: '#333',
//   },
//   button: {
//     marginTop: 20,
//     borderRadius: 10,
//     padding: 12,
//     backgroundColor: '#007AFF',
//   },
//   buttonText: {
//     color: 'white',
//     fontWeight: 'bold',
//     textAlign: 'center',
//   },
// });

// export default ScpTransferLogs;
