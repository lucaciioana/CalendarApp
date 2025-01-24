import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
    static values = {
        autoHide: String,
        duration: String
    }

    connect() {
        if (this.autoHideValue === "true" || this.autoHideValue === "") {
            const duration = this.durationValue ? Number(this.durationValue) : 5000
            setTimeout(() => {
                this.dismiss()
            }, duration)
        }
    }

    dismiss() {
        this.element.remove()
    }
}
