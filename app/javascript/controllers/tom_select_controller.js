import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="tom-select"
export default class extends Controller {
	connect() {
		this.select = new TomSelect(this.element, {
			plugins: ['remove_button'],
  		create: input => {
				return {
					value: `new: ${input}`, 
					text: input
				};
		},
			persist: false,
			maxItems: null, 
			placeholder: this.element.getAttribute("placeholder") || ""
		})
	}
	disconnect(){
		this.select?.destroy()
	}
}
