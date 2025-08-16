import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="instant-search"
export default class extends Controller {
  connect() {
  }

	autosubmit(){
		// フォーム入力から200ms後にリクエストを実行する
		clearTimeout(this.timeout)
		this.timeout = setTimeout(() => {
			this.element.requestSubmit()
		}, 200)
	}
}
