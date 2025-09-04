import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="drawer"
export default class extends Controller {
	static targets = ["toggle"]
  connect() {
  }

	open() {
		this.toggleTarget.checked = true;
	}
		
	close() {
		this.toggleTarget.checked = false;
	}

}
