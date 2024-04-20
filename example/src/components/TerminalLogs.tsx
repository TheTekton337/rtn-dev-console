import React, { useEffect, useState, type FC } from 'react';
import {
  Modal,
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  FlatList,
} from 'react-native';

import type { LogEntry } from '../types/Log';

import { logDataService } from '../observables/LogDataService';
import { modalStateService } from '../observables/ModalStateService';

export interface TerminalLogsProps {
  terminalId: string;
  onClose?: () => void;
}

// TODO: Move to component dir
interface LogItem {
  item: LogEntry;
  index: number;
}

// TODO: Add comments

const TerminalLogsDisplay: FC<TerminalLogsProps> = ({
  terminalId,
  onClose,
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const [logs, setLogs] = useState<LogEntry[]>([]);

  useEffect(() => {
    modalStateService.registerModal(terminalId);

    const visibilitySubscription = modalStateService
      .getVisibilityState(terminalId)
      .subscribe(setIsVisible);

    const logSubscription = logDataService
      .getLogEntries(terminalId)
      .subscribe(setLogs);
    return () => {
      logDataService.clearLogEntries(terminalId);

      visibilitySubscription.unsubscribe();
      logSubscription.unsubscribe();
    };
  }, [terminalId]);

  const renderItem = ({ item, index }: LogItem) => (
    <Text key={index} style={styles.logText}>
      {item.message}
    </Text>
  );

  const onClosePressed = () => {
    modalStateService.toggleModal(terminalId);
    onClose && onClose();
  };

  return (
    <Modal
      animationType="slide"
      transparent={true}
      visible={isVisible}
      onRequestClose={onClosePressed}
    >
      <View style={styles.centeredView}>
        <View style={styles.modalView}>
          <FlatList
            data={logs}
            renderItem={renderItem}
            keyExtractor={(_item, index) => `log-item-${index}`}
            contentContainerStyle={styles.logsContainer}
          />
          <TouchableOpacity style={styles.button} onPress={onClosePressed}>
            <Text style={styles.buttonText}>Close</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  centeredView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalView: {
    width: '90%',
    minHeight: '80%',
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 4.84,
    elevation: 5,
    overflow: 'hidden',
  },
  logsContainer: {
    width: '100%',
  },
  logText: {
    marginBottom: 10,
    textAlign: 'left',
    color: '#333',
  },
  button: {
    marginTop: 20,
    borderRadius: 10,
    padding: 12,
    backgroundColor: '#007AFF',
  },
  buttonText: {
    color: 'white',
    fontWeight: 'bold',
    textAlign: 'center',
  },
});

export default TerminalLogsDisplay;
