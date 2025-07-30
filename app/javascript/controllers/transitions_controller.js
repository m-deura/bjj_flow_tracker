import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transitions"
export default class extends Controller {
  static targets = ["list", "template"]
  add() {
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.listTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    const record = event.target.closest("[data-new-record]")
    if (!record) return

    // `_destroy` hidden field があればチェックをつけて非表示
    const destroyField = record.querySelector("input[name*='_destroy']")
    if (destroyField) {
      destroyField.value = "1"
      record.style.display = "none"
    } else {
      // 新規追加分はDOMから削除
      record.remove()
    }
  }
}
