import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="grid"
export default class extends Controller {
    static targets = ["parent", "child", 'delete']

    connect() {
        // reset on page refresh
        this.childTargets.map(x => x.checked = false)
        this.parentTarget.checked = false
    }

    toggleChildren() {
        if (this.parentTarget.checked) {
            this.childTargets.map(x => x.checked = true)
            // this.childTargets.forEach((child) => {
            //   child.checked = true
            // })
            this.deleteTarget.disabled = false
        } else {
            this.childTargets.map(x => x.checked = false)
            this.deleteTarget.disabled = true
        }
    }

    toggleParent() {
        if (this.childTargets.map(x => x.checked).includes(false)) {
            // enable/disable delete btn
            const count = this.childTargets.filter(x => x.checked).length
            this.deleteTarget.disabled = count === 0
            // mark the target as false
            this.parentTarget.checked = false
        } else {
            this.parentTarget.checked = true
            const count = this.childTargets.filter(x => x.checked).length
            this.deleteTarget.disabled = count === 0
        }

    }
}
