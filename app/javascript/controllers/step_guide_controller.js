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

	  // 未翻訳かどうかの判定ヘルパ
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

      // selector は“文言”ではないが i18n から取る（無ければ null）
      const selector = this.tOrNull(`${base}.selector`) || null
      const part = {}
      if (title) part.title = title
      if (intro) part.intro = intro

      if (selector) {
        // セレクタ要素が存在しない場合は“全体ステップ”として落とす（スキップしたければ continue）
        if (document.querySelector(selector)) {
          steps.push({ element: selector, ...part })
        } else {
          steps.push(part)
        }
      } else {
        steps.push(part)
      }
    }
    return steps
  }

  // どのガイドでも共通起動
  start() {
    const steps = this.buildSteps()
    if (!steps.length) return
    introJs().setOptions({ steps, showBullets: false, showProgress: true }).start()
  }

	stepPart(stepId) {
		const k = `${this.scopeKey}.${stepId}`;
		const vars = { techniques_path: this.techniques_path, charts_path: this.charts_path };

		const titleStr = this.i18n.t(`${k}.title`);
		const introStr = this.i18n.t(`${k}.intro_html`, vars);

		// i18n-js は未定義キーだと "[missing ...]" を返す → それで判定
		const isMissing = (s) => typeof s === "string" && /^\[missing /.test(s);

		const part = {};
		if (!isMissing(titleStr)) part.title = titleStr;
		if (!isMissing(introStr)) part.intro = introStr;

  	// どちらも無ければ null を返す。後に個々のstepguideにて　filter(Boolean)でnull削除。
  	return Object.keys(part).length ? part : null;
	}

	startDashboardGuide() {
		this.start()
	}

	startTechniqueGuide() {
		const intro = introJs.tour().setOptions({
			steps: [
				{
					intro: step0.dataset.introText
				},
				{
					element: step1,
					title: step1.dataset.titleText,
					intro: step1.dataset.introText
				},
				{
					element: step2,
					title: step2.dataset.titleText,
					intro: step2.dataset.introText
				},
				{
					title: step3.dataset.titleText,
					intro: step3.dataset.introText
				},
				{
					element: document.querySelector(".drawer-side"),
					title: step4.dataset.titleText,
					intro: step4.dataset.introText,
					// ハイライトが当たった展開済みカードが閉じられないようにする
					disableInteraction: true
				},
				{
					title: step5.dataset.titleText,
					intro: step5.dataset.introText,
				},
			], 
			showBullets: false, // カード展開がある都合上、ガイドステップのスキップ要制御
			showProgress: true // Bulletsの代替となるガイド進行状況確認用UI
		})

	intro.onAfterChange((el) => {
  	// console.log("今ハイライトしてるのは:", el)
		// console.log(intro.getCurrentStep())

		// 一番上にあるカードを展開し、カード内部(テクニック詳細画面)の説明をする。
		if (intro.getCurrentStep() === 3) {
			const firstCard = document.querySelector("a[data-turbo-frame='technique-drawer']");
			if (firstCard) firstCard.click();
			}
	})
		intro.start();
		// console.log(intro)
	}

	startChartGuide() {
		const step0 = document.querySelector("#step0")
		const step1 = document.querySelector("#step1")
		const step2 = document.querySelector("#step2")
		const step3 = document.querySelector("#step3")

		const intro = introJs.tour().setOptions({
			steps: [
				{
					intro: step0.dataset.introText
				},
				{
					element: step1,
					title: step1.dataset.titleText,
					intro: step1.dataset.introText
				},
				{
					element: step2,
					title: step2.dataset.titleText,
					intro: step2.dataset.introText
				},
				{ element: step3,
					title: step3.dataset.titleText,
					intro: step3.dataset.introText,
					disableInteraction: true
				},
			], 
			showBullets: false, 
			showProgress: true
		})

		intro.onAfterChange(() => {
			// step2の時、chart_controllerに頼んでドロワーを開く。
			if (intro.getCurrentStep() === 2) {
				this.dispatch("openNode");
			}
		});

		intro.start();
	}

	startNodeGuide(){
		const step0 = document.querySelector("#step0n")
		const step1 = document.querySelector("#step1n")
		const step2 = document.querySelector("#step2n")
		const step3 = document.querySelector("#step3n")
		const step4 = document.querySelector("#step4n")

		const intro = introJs.tour().setOptions({
			steps: [
				{
					intro: step0.dataset.introText,
					disableInteraction: true
				},
				{
					element: step1,
					title: step1.dataset.titleText,
					intro: step1.dataset.introText,
					disableInteraction: true
				},
				{
					element: step2,
					title: step2.dataset.titleText,
					intro: step2.dataset.introText,
					disableInteraction: true
				},
				{ 
					element: step3,
					title: step3.dataset.titleText,
					intro: step3.dataset.introText,
					disableInteraction: true
				},
				{
					title: step4.dataset.titleText,
					intro: step4.dataset.introText,
					disableInteraction: true
				},
			], 
			showBullets: false, 
			showProgress: true
		})

		intro.onBeforeChange(() => {
			intro.refresh();
			// 小さい画面だと最終ステップガイドが見切れるため、画面上部へ自動スクロール。
			if (intro.getCurrentStep() === 4) {
				window.scrollTo({ top: 0, behavior: "smooth" })
			}
		});

		intro.start();
	}
}
