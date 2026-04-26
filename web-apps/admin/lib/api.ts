import { cookies } from "next/headers";
import { mock, type Food, type Nutrient, type User, type MealLog, type ReminderTemplate, type Overview } from "./mock";
import { ADMIN_ACCESS_COOKIE, ADMIN_REFRESH_COOKIE } from "./auth-cookies";

const BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/v1";
const ALLOW_MOCKS = process.env.NEXT_PUBLIC_ALLOW_MOCKS === "true";
export { ADMIN_ACCESS_COOKIE, ADMIN_REFRESH_COOKIE };

export class ApiError extends Error {
  constructor(message: string, readonly status?: number) {
    super(message);
  }
}

export async function backendFetch(path: string, init: RequestInit = {}): Promise<Response> {
  const cookieStore = await cookies();
  const access = cookieStore.get(ADMIN_ACCESS_COOKIE)?.value;
  const headers = new Headers(init.headers);
  headers.set("Accept", "application/json");
  if (!(init.body instanceof FormData)) {
    headers.set("Content-Type", headers.get("Content-Type") ?? "application/json");
  }
  if (access) {
    headers.set("Authorization", `Bearer ${access}`);
  }
  return fetch(`${BASE}${path}`, {
    ...init,
    headers,
    cache: "no-store",
  });
}

async function fetchJson(path: string, init: RequestInit = {}): Promise<unknown> {
  const res = await backendFetch(path, init);
  if (!res.ok) {
    let message = `Backend request failed (${res.status})`;
    try {
      const body = await res.json();
      if (body && typeof body === "object" && "error" in body) {
        message = String((body as { error: unknown }).error);
      }
    } catch {
      // Keep status-based message.
    }
    throw new ApiError(message, res.status);
  }
  if (res.status === 204) return null;
  return res.json();
}

function logFallback(path: string) {
  if (typeof window !== "undefined") {
    // eslint-disable-next-line no-console
    console.info(`[api] mock fallback for ${path}`);
  }
}

async function tryGet<T>(path: string, pick: (raw: unknown) => T | undefined, fallback: T): Promise<T> {
  try {
    const raw = await fetchJson(path);
    const got = pick(raw);
    if (got === undefined) throw new ApiError("Unexpected backend response shape");
    return got;
  } catch (error) {
    if (ALLOW_MOCKS) {
      logFallback(path);
      return fallback;
    }
    throw error;
  }
}

const asArray = <T>(v: unknown): T[] | undefined => (Array.isArray(v) ? (v as T[]) : undefined);

function normalizeFood(raw: Record<string, unknown>): Food {
  const nutrients = Array.isArray(raw.nutrients) ? raw.nutrients : [];
  return {
    id: String(raw.id ?? ""),
    name: String(raw.name ?? "(unnamed)"),
    brand: (raw.brand as string | undefined) ?? undefined,
    category: String(raw.category ?? "general"),
    servingSizeG: Number(raw.servingSizeG ?? raw.serving_size_g ?? 100),
    source: normalizeSource(raw.source),
    verified: Boolean(raw.verified),
    updatedAt: String(raw.updatedAt ?? raw.updated_at ?? raw.created_at ?? new Date().toISOString()),
    nutrients: nutrients.map((n) => {
      if (typeof n === "string") {
        return { code: n as Food["nutrients"][number]["code"], name: n, amount: 0, unit: "" };
      }
      const nn = n as Record<string, unknown>;
      return {
        code: (nn.code as Food["nutrients"][number]["code"]) ?? "C",
        name: String(nn.name ?? nn.code ?? ""),
        amount: Number(nn.amount ?? nn.amount_per_100g ?? 0),
        unit: String(nn.unit ?? ""),
      };
    }),
  };
}

function normalizeSource(value: unknown): Food["source"] {
  if (value === "seed" || value === "manual" || value === "user_submitted") return value;
  if (value === "user") return "user_submitted";
  return "manual";
}

function pickEnvelopeArray<T>(key: string) {
  return (raw: unknown): T[] | undefined => {
    if (Array.isArray(raw)) return raw as T[];
    if (raw && typeof raw === "object" && key in raw && Array.isArray((raw as Record<string, unknown>)[key])) {
      return (raw as Record<string, unknown>)[key] as T[];
    }
    return undefined;
  };
}

const pickFoods = (raw: unknown): Food[] | undefined => {
  const arr = pickEnvelopeArray<unknown>("foods")(raw);
  return arr?.map((r) => normalizeFood(r as Record<string, unknown>));
};

const pickFood = (raw: unknown): Food | undefined => {
  if (!raw || typeof raw !== "object") return undefined;
  const obj = "food" in raw ? (raw as { food: unknown }).food : raw;
  if (!obj || typeof obj !== "object") return undefined;
  return normalizeFood(obj as Record<string, unknown>);
};

const pickOverview = (raw: unknown): Overview | undefined => {
  if (raw && typeof raw === "object" && "kpis" in raw) return raw as Overview;
  return undefined;
};

export const api = {
  listFoods: () => tryGet<Food[]>("/admin/foods?limit=100", pickFoods, mock.foods),
  getFood: (id: string) => tryGet<Food>(`/admin/foods?limit=100`, (raw) => pickFoods(raw)?.find((f) => f.id === id), mock.foods.find((f) => f.id === id) ?? mock.foods[0])
    .then(async (summary) => {
      const detail = await tryGet<Food>(`/foods/${id}`, pickFood, summary);
      return { ...summary, ...detail };
    }),
  listNutrients: () => tryGet<Nutrient[]>("/admin/nutrients", pickEnvelopeArray<Nutrient>("nutrients"), mock.nutrients),
  listMealLogs: () => tryGet<MealLog[]>("/admin/logs?limit=50", pickEnvelopeArray<MealLog>("logs"), mock.mealLogs),
  listUsers: () => tryGet<User[]>("/admin/users?limit=50", pickEnvelopeArray<User>("users"), mock.users),
  getUser: (id: string) => tryGet<User>(`/admin/users/${id}`, (raw) => (raw && typeof raw === "object" && "id" in raw ? (raw as User) : undefined), mock.users.find((u) => u.id === id) ?? mock.users[0]),
  listReminderTemplates: () => tryGet<ReminderTemplate[]>("/admin/reminders?limit=50", (raw) => {
    const reminders = pickEnvelopeArray<Record<string, unknown>>("reminders")(raw);
    return reminders?.map((r) => ({
      id: String(r.id ?? ""),
      title: String(r.title ?? ""),
      body: String(r.body ?? "Reminder"),
      trigger: String(r.trigger ?? r.remindAt ?? ""),
      audience: String(r.audience ?? r.userEmail ?? "User"),
      sent7d: Number(r.sent7d ?? 0),
      active: Boolean(r.active),
    }));
  }, mock.reminderTemplates),
  overview: () => tryGet<Overview>("/admin/overview", pickOverview, mock.overview),
};

export const rawApi = {
  login: (email: string, password: string) => fetch(`${BASE}/admin/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify({ email, password }),
    cache: "no-store",
  }),
  logout: () => backendFetch("/auth/logout", { method: "POST" }),
};
