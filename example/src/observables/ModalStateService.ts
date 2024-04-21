import { BehaviorSubject } from 'rxjs';
import { map } from 'rxjs/operators';

const modalVisibilitySubject = new BehaviorSubject<{ [key: string]: boolean }>(
  {}
);

/**
 * Toggles the visibility state of a modal identified by modalId.
 * If the modal does not exist, it initializes it as false and then toggles to true.
 * @param modalId The unique identifier for the modal.
 */
export function toggleModal(modalId: string) {
  const currentVisibility = modalVisibilitySubject.getValue();
  // Initialize with false if not existent, then toggle
  const isVisible =
    modalId in currentVisibility ? currentVisibility[modalId] : false;
  modalVisibilitySubject.next({
    ...currentVisibility,
    [modalId]: !isVisible,
  });
}

/**
 * Provides an observable that emits the visibility state of a specific modal.
 * Ensures false as default if the modal has not been initialized.
 * @param modalId The unique identifier for the modal.
 * @returns An observable that emits a boolean representing the visibility state.
 */
export function getVisibilityState(modalId: string) {
  return modalVisibilitySubject
    .asObservable()
    .pipe(map((visibility) => visibility[modalId] || false));
}

/**
 * Registers a modal with an initial visibility state of false, if it has not already been set.
 * This ensures that the modal has a defined state in the BehaviorSubject.
 * @param modalId The unique identifier for the modal.
 */
export function registerModal(modalId: string) {
  const currentVisibility = modalVisibilitySubject.getValue();
  if (!(modalId in currentVisibility)) {
    modalVisibilitySubject.next({
      ...currentVisibility,
      [modalId]: false,
    });
  }
}

export const modalVisibilityObservable = modalVisibilitySubject.asObservable();
