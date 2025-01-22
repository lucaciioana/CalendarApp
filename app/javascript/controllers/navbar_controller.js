import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
    static targets = ['profile']
    connect() {
        // On page load or when changing themes, best to add inline in `head` to avoid FOUC
        document.documentElement.classList.toggle(
            'dark',
            localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches));
    }

    changeTheme(arg) {
        localStorage.theme = arg;
    }

    resetTheme(arg) {
        localStorage.removeItem('theme');
    }


    toggleProfile() {

    }

}
