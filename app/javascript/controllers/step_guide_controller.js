import { Controller } from "@hotwired/stimulus"
import introJs from "intro.js"

// Connects to data-controller="step-guide"
export default class extends Controller {
  connect() {
  }

	startMenuGuide() {
		console.log("MenuGuide started!")
	}
}
