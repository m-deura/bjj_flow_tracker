import { Controller } from "@hotwired/stimulus"
import { ensureI18n } from "../i18n/loader"
import { driver } from "driver.js";

// Connects to data-controller="step-guide"
export default class extends Controller {
	static values = {
		scope: String,
		techniquesPath: String,
		chartsPath: String
	}

  async connect() {
		this.i18n = await ensureI18n();
		this.scopeKey = this.scopeValue;
		this.vars = {
			techniques_path: this.techniquesPathValue || "",
			charts_path: this.chartsPathValue || ""
		}
	}

	// YAMLの scope オブジェクトを取得
	scopeDict() {
		const parts = this.scopeKey.split(".")
		let current = this.i18n.translations?.[this.i18n.locale]
		for (const p of parts) current = current?.[p]
		return current || null
	}

	// 未翻訳かどうかの判定ヘルパー
	// vars で指定されたものを i18n-js のinterpolation(e.g. %{technique_path]}) を使って置換
	tOrNull(key, vars = {}) {
		const s = this.i18n.t(key, vars)
		return (typeof s === "string" && /^\[missing /.test(s)) ? null : s
	}

	// YAMLから step* を自動収集→並べ替え→steps配列へ
	buildSteps() {
		const dict = this.scopeDict()
		if (!dict) return []
		
		// stepキーを抽出して昇順に並べる
		// \Dは「数字じゃない文字」= step
		const stepKeys = Object.keys(dict)
			.filter(k => /^step\d+$/i.test(k))
			.sort((a, b) => parseInt(a.replace(/\D/g, ""), 10) - parseInt(b.replace(/\D/g, ""), 10))
		
		const steps = []
		for (const step of stepKeys) {
			const base = `${this.scopeKey}.${step}`
			const title = this.tOrNull(`${base}.title`)
			const description = this.tOrNull(`${base}.description`, this.vars)
			if (!title && !description) continue  // どちらも無ければスキップ
		
			// element も i18n から取得する（無ければ null）
			const element = this.tOrNull(`${base}.element`) || null
			const popover = {}
			if (title) popover.title = title
			if (description) popover.description = description

			// ハイライトが当たった展開済みカードやドロワーが閉じられないようにする
			const common = { popover, disableActiveInteraction: true }

			if (element) {
				// セレクタ要素が存在しない場合は“全体ステップ”として落とす（スキップしたければ continue）
				if (document.querySelector(element)) {
					steps.push({ element: element, ...common })
				} else {
					steps.push(common)
				}
			} else {
				steps.push(common)
			}
		}
		return steps
	}

	// どのガイドでも共通起動
	start(onStepHighlighted) {
		const steps = this.buildSteps()
		if (!steps.length) return

		this._driver = driver({
			steps,
			onHighlighted: (_el, _step, { driver: drv }) => { // 第三引数の options から driver だけを drv という名前で分割代入を使って取り出す 
				if (typeof onStepHighlighted === "function") onStepHighlighted(drv)
			},
		})

		this._driver.drive()
  }

	startDashboardGuide() {
		this.start()
	}

	startTechniqueGuide() {
		this.start((drv) => {
			// ガイドの途中でテクニック詳細・編集画面を開く。
			if (drv.getActiveIndex() === 4) {
				const firstCard = document.querySelector("a[data-turbo-frame='technique-drawer']")
				if (firstCard) firstCard.click()
			}
		});
	}

	startChartListGuide() {
		this.start()
	}

	startChartGuide() {
		const controller = this; // ← Stimulusのthisを退避

		this.start((drv) => {
			// step2の時、chart_controllerに頼んでドロワーを開く。
			if (drv.getActiveIndex() === 2) {
				controller.dispatch("openNode"); 
				// アロー関数じゃないので、ここでthis.dispatchと書くとthisはdriver()を指すようになる。
				// アロー関数は外側のthisを使う一方、function() の場合thisは呼び出し側が決める仕様。
			}
		});
	}

	startNodeGuide(){
		this.start()
	}
}
