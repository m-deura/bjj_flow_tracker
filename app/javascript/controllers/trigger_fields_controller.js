import { Controller } from "@hotwired/stimulus"
import { ensureI18n } from "../i18n/loader"

// Connects to data-controller="trigger-fields"
export default class extends Controller {
  static targets = ["select", "fields"]
  static values = { 
    existingTriggers: Object,  // 既存トリガーの初期値（technique_id文字列 or "new: XXX" → trigger）
  }

  async connect() {
		// i18n のロードを待ってから描画
    this.i18n = await ensureI18n()

    // 初期描画（編集画面の初期選択やTurbo再描画にも対応）
    this.renderFields()

    // changeで展開先テクニックフィールドの変化を監視
    this.selectTarget.addEventListener("change", () => this.renderFields())
  }

  renderFields() {
    const values = this.currentValues() // ["3", "42", "new: アームバー"] など
    // いったんクリア
    this.fieldsTarget.innerHTML = ""

    if (values.length === 0) return

		// <fieldset>
	  const fieldset = document.createElement("fieldset")
    fieldset.className = "space-y-2"

    // <legend>
    const legend = document.createElement("legend")
    legend.className = "mt-5"
    legend.innerHTML = `<span>${this.t("helpers.label.triggers")}</span>`
    fieldset.appendChild(legend)

		// 各行（<label>で包めば for/id 不要）
    values.forEach((rawKey) => {
      const row = document.createElement("label")
      row.className = "block gap-2"

      const badge = document.createElement("span")
      badge.className = "badge badge-outline mb-1"
      badge.textContent = this.displayName(rawKey)
      row.appendChild(badge)

      const input = document.createElement("input")
      input.type = "text"
      input.name = `node_edit_form[triggers][${rawKey}]`
      input.className = "input input-bordered w-full"
      input.placeholder = this.t("defaults.trigger")
      input.value = this.prefillFor(rawKey) || ""
      row.appendChild(input)

      fieldset.appendChild(row)
    })

    this.fieldsTarget.appendChild(fieldset)
		console.log(this.selectTarget.options)
  }

  currentValues() {
		const el = this.selectTarget
    return Array.from(el.selectedOptions).map(o => o.value)
  }

	displayName(value) {
    // まずセレクトの option から表示名を取得
    const opt = Array.from(this.selectTarget.options).find(o => o.value === value)
    if (opt) return opt.text
  }

  prefillFor(rawKey) {
    if (!this.hasExistingTriggersValue) return null
    return this.existingTriggersValue?.[rawKey] || null
  }

  // フォームのラベル・プレースホルダーに対するI18n対応
  t(key, opts = {}) {
		if (this.i18n) return this.i18n.t(key, opts)
  }

  disconnect() {
    this.selectTarget.removeEventListener("change", this.renderFields)
  }
}
