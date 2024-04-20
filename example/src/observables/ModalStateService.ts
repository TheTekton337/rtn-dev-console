import { BehaviorSubject, map } from 'rxjs';

// TODO: Improve comments
// TODO: Refactor functional or OO for these services, but pick one (functional)
class ModalStateService {
  private modalVisibilitySubject = new BehaviorSubject<{
    [key: string]: boolean;
  }>({});

  // Initialize or toggle modal visibility
  public toggleModal(modalId: string) {
    const currentVisibility = this.modalVisibilitySubject.getValue();
    // Initialize with false if not existent, then toggle
    const isVisible =
      modalId in currentVisibility ? currentVisibility[modalId] : false;
    this.modalVisibilitySubject.next({
      ...currentVisibility,
      [modalId]: !isVisible,
    });
  }

  // Provide a way to get the visibility state for a specific modal
  public getVisibilityState(modalId: string) {
    return this.modalVisibilitySubject.asObservable().pipe(
      map((visibility) => visibility[modalId] || false) // Ensure false as default if not initialized
    );
  }

  // Optional: Initialize a modal's visibility state if not already set
  public registerModal(modalId: string) {
    const currentVisibility = this.modalVisibilitySubject.getValue();
    if (!(modalId in currentVisibility)) {
      this.modalVisibilitySubject.next({
        ...currentVisibility,
        [modalId]: false,
      });
    }
  }
}

export const modalStateService = new ModalStateService();
