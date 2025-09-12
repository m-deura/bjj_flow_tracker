import { I18n } from "i18n-js";

let currentLocale = null;
let initPromise = null;
let i18n = null;

function detectLocale() {
	// URL /ja/... or <html lang="ja"> のどちらか
	const lang = document.documentElement.getAttribute("lang");
	if (lang) return lang;
	const seg = location.pathname.split("/")[1];
	return ["ja", "en"].includes(seg) ? seg : "ja";
}

async function importDict(locale) {
	const raw = (await import(`../locales/${locale}.json`));
  return raw[locale] // ロケール配下だけ返す
}

// 何度呼ばれても同じロケールなら再ロードしない
export async function ensureI18n() {
	const locale = detectLocale();
	if (initPromise && currentLocale === locale) return initPromise;

	initPromise = (async () => {
		const dict = await importDict(locale);

		if (!i18n) {
			i18n = new I18n({ [locale]: dict });
			i18n.defaultLocale = "ja";
			i18n.locale = locale;
			i18n.enableFallback = true;
		} else {
			i18n.translations = { [locale]: dict };
			i18n.locale = locale;
		}

		return i18n;
	})();

	currentLocale = locale;
	return initPromise;
}
