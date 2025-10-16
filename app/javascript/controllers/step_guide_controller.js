import { Controller } from "@hotwired/stimulus"
import introJs from "intro.js"
import { ensureI18n } from "../i18n/loader"

// Connects to data-controller="step-guide"
export default class extends Controller {
	static values = {
		scope: String,
		techniquesPath: String,
		chartsPath: String
	}

  async connect() {
		// introJs.tour().setOption("dontShowAgain", true).start();
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
	tOrNull(key, vars = {}) {
		const s = this.i18n.t(key, vars)
		return (typeof s === "string" && /^\[missing /.test(s)) ? null : s
	}

	// YAMLから step* を自動収集→並べ替え→steps配列へ
	buildSteps() {
		const dict = this.scopeDict()
		if (!dict) return []
		
		// stepキーを抽出して数値順に
		const stepKeys = Object.keys(dict)
			.filter(k => /^step\d+$/i.test(k))
			.sort((a, b) => parseInt(a.replace(/\D/g, ""), 10) - parseInt(b.replace(/\D/g, ""), 10))
		
		const steps = []
		for (const step of stepKeys) {
			const base = `${this.scopeKey}.${step}`
			const title = this.tOrNull(`${base}.title`)
			const intro = this.tOrNull(`${base}.intro_html`, this.vars)
			if (!title && !intro) continue  // どちらも無ければスキップ
		
			// selector も i18n から取得する（無ければ null）
			const selector = this.tOrNull(`${base}.selector`) || null
			const part = {}
			if (title) part.title = title
			if (intro) part.intro = intro

			// ハイライトが当たった展開済みカードやドロワーが閉じられないようにする
			const common = { ...part, disableInteraction: true }

			if (selector) {
				// セレクタ要素が存在しない場合は“全体ステップ”として落とす（スキップしたければ continue）
				if (document.querySelector(selector)) {
					steps.push({ element: selector, ...common })
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
	start(onafterchange) {
		const steps = this.buildSteps();
		if (!steps.length) return;

		const tour = introJs.tour().setOptions({
			steps,
			showBullets: false,
			showProgress: true,
		});

		if (onafterchange) tour.onAfterChange(onafterchange);
		tour.start();
	}

	startDashboardGuide() {
		this.start()
	}

	startTechniqueGuide() {
		this.start(function () {
			if (this.getCurrentStep() === 3) {
				const firstCard = document.querySelector("a[data-turbo-frame='technique-drawer']");
				if (firstCard) firstCard.click();
			}
		});
	}

	startChartListGuide() {
		this.start()
	}

	startChartGuide() {
		const controller = this; // ← Stimulusのthisを退避

		this.start(function() {
			// step2の時、chart_controllerに頼んでドロワーを開く。
			if (this.getCurrentStep() === 2) {
				controller.dispatch("openNode"); 
				// アロー関数じゃないので、ここでthis.dispatchと書くとthisはtour()を指すようになる。
				// アロー関数は外側のthisを使う一方、function() の場合thisは呼び出し側が決める仕様。
			}
		});
	}

	startNodeGuide(){
		this.start(function() {
			this.refresh();
			// 小さい画面だと最終ステップガイドが見切れるため、画面上部へ自動スクロール。
			if (this.getCurrentStep() === 4) {
				window.scrollTo({ top: 0, behavior: "smooth" })
			}
		});
	}
}
