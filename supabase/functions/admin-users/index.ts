// 管理者だけが使える「ユーザー管理」の裏方（Supabase Edge Function）
// できること：create（アカウント作成）／setPassword（パスワード変更）／delete（アカウント削除）
// 呼び出した人がアプリ上の「管理者」かどうかを app_state の staff で確認してから実行します。
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
    const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const authHeader = req.headers.get("Authorization") || "";

    // 1) 呼び出した本人を確認
    const me = createClient(url, anon, { global: { headers: { Authorization: authHeader } } });
    const { data: { user } } = await me.auth.getUser();
    if (!user || !user.email) return json({ error: "ログインが必要です" }, 401);

    // 2) アプリ上で管理者か確認
    const { data: row } = await me.from("app_state").select("value").eq("key", "plus_estimate_shared_v2").maybeSingle();
    const state = row ? JSON.parse(row.value) : null;
    const staff = (state?.staff || []) as Array<{ email: string; role: string; active?: boolean }>;
    const meStaff = staff.find((s) => s.email.toLowerCase() === user.email!.toLowerCase());
    if (!meStaff || meStaff.role !== "管理者" || meStaff.active === false) return json({ error: "管理者のみ操作できます" }, 403);

    // 3) 管理用の権限で実行
    const admin = createClient(url, service);
    const body = await req.json();
    const email = String(body.email || "").trim().toLowerCase();
    if (!email) return json({ error: "メールアドレスがありません" }, 400);

    const findUser = async () => {
      for (let page = 1; page < 50; page++) {
        const { data, error } = await admin.auth.admin.listUsers({ page, perPage: 200 });
        if (error) throw error;
        const u = data.users.find((x) => (x.email || "").toLowerCase() === email);
        if (u) return u;
        if (data.users.length < 200) return null;
      }
      return null;
    };

    if (body.action === "create") {
      if (String(body.password || "").length < 6) return json({ error: "パスワードは6文字以上" }, 400);
      const exists = await findUser();
      if (exists) {
        const { error } = await admin.auth.admin.updateUserById(exists.id, { password: body.password, email_confirm: true });
        if (error) return json({ error: error.message }, 400);
        return json({ ok: true, id: exists.id, updated: true });
      }
      const { data, error } = await admin.auth.admin.createUser({ email, password: body.password, email_confirm: true });
      if (error) return json({ error: error.message }, 400);
      return json({ ok: true, id: data.user?.id });
    }
    if (body.action === "setPassword") {
      if (String(body.password || "").length < 6) return json({ error: "パスワードは6文字以上" }, 400);
      const u = await findUser();
      if (!u) return json({ error: "そのメールアドレスのアカウントが見つかりません" }, 404);
      const { error } = await admin.auth.admin.updateUserById(u.id, { password: body.password });
      if (error) return json({ error: error.message }, 400);
      return json({ ok: true });
    }
    if (body.action === "delete") {
      if (email === user.email.toLowerCase()) return json({ error: "自分自身は削除できません" }, 400);
      const u = await findUser();
      if (u) {
        const { error } = await admin.auth.admin.deleteUser(u.id);
        if (error) return json({ error: error.message }, 400);
      }
      return json({ ok: true });
    }
    return json({ error: "不明な操作です" }, 400);
  } catch (e) {
    return json({ error: (e as Error).message || String(e) }, 500);
  }
});
