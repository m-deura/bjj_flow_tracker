import { Controller } from "@hotwired/stimulus"
import introJs from "intro.js"

// Connects to data-controller="step-guide"
export default class extends Controller {
  connect() {
		// introJs.tour().setOption("dontShowAgain", true).start();
  }

	startMenuGuide() {
		// console.log("MenuGuide started!")
		introJs.tour().start();
	}
}
