import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="modals"
export default class extends Controller {
    static targets = ["modal"]

    closeHandler(event) {
        if (event.keyCode === 27) {
            this.close();
        }
    }

    close() {
        this.modalTarget.style.display = 'none';
        this.modalTarget.innerHTML = '';
        this.modalTarget.removeAttribute('src');
        this.modalTarget.removeAttribute('completed');
    }

    submit(payload) {

    }

}
