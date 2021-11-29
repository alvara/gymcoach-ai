import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ['speech'];

  connect() {
    const synth = window.speechSynthesis;
    if (this.element.dataset.spoken === "false") {
      const textString = this.speechTarget.textContent;
      const convertedTextString = new SpeechSynthesisUtterance(textString);
      synth.speak(convertedTextString);
      this.element.dataset.spoken = "true";
    }
  }

  speak() {

  }
}