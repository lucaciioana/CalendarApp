import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="events"
export default class extends Controller {
  static targets = ["select", "repeatable"]
  connect() {
    console.log('eventsControllerConnect')
    // this.toggleRepeatableSection();
  }

  toggleRepeatableSection(){
    console.log("toggleRepeatableSection");
    if (this.selectTarget.value === 'true') {
      this.repeatableTarget.style.display = 'block';
    } else {
      this.repeatableTarget.style.display = 'none';
    }
  }
}
