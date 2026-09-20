// 本番のクラウド（Supabase）に接続するときは、supabaseUrl と supabaseAnonKey を入れてください。
// 空のままなら、端末内（またはClaudeアプリ内）の保存先で動きます。
window.APP_CONFIG = {
  supabaseUrl: "",      // 例: "https://xxxxxxxx.supabase.co"
  supabaseAnonKey: "",  // Supabase の Project Settings → API → anon public
  demoData: true        // true：お試し用の顧客・見積を最初から入れる（試作品リリース用）
                        // false：空の状態で始める（本運用用）。あとから「設定 → サンプルデータを削除」でも消せます
};
