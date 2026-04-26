import { api } from "@/lib/api";
import { PageHeader } from "@/components/ui/PageHeader";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Chip } from "@/components/ui/Chip";
import { Avatar } from "@/components/ui/Avatar";
import { KpiCard } from "@/components/ui/KpiCard";
import { NutrientPill } from "@/components/ui/NutrientPill";
import { fmtRelative } from "@/lib/utils";

export const dynamic = "force-dynamic";

export default async function UserDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const user = await api.getUser(id);

  return (
    <div className="p-8">
      <PageHeader
        title=""
        actions={
          <>
            <Button variant="ghost" size="sm">Send password reset</Button>
            <Button variant="ghost" size="sm">Impersonate</Button>
          </>
        }
      />

      <Card className="!p-6 mb-4">
        <div className="grid grid-cols-[auto_1fr_auto] gap-6 items-center">
          <Avatar initials={user.initials} seed={user.email} size="lg" />
          <div>
            <div className="flex items-center gap-3 mb-1">
              <h1 className="text-2xl font-bold tracking-tight">{user.displayName}</h1>
              {user.status === "verified" && <Chip variant="accent" dot>Verified</Chip>}
              {user.status === "unverified" && <Chip variant="warn" dot>Unverified</Chip>}
              {user.status === "pending_deletion" && <Chip variant="err" dot>Pending deletion</Chip>}
            </div>
            <div className="flex flex-wrap gap-x-6 gap-y-1 text-[13px] text-[var(--color-text-muted)]">
              <span>{user.email}</span>
              {user.sex && user.age && <span className="capitalize">{user.sex} · {user.age} · {user.activity} activity</span>}
              <span>Joined {user.joined}</span>
              <span>{user.platform} · v1.4.2</span>
            </div>
          </div>
          <div className="flex gap-2">
            <Button variant="ghost" size="sm">Revoke sessions</Button>
            <Button variant="danger" size="sm">Delete account</Button>
          </div>
        </div>
      </Card>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <KpiCard label="Logs (30d)" value={user.logs30d} delta={{ value: 6.2, suffix: "vs prev", up: true }} />
        <KpiCard label="Avg DRI coverage" value={76} suffix="%" helper="10 nutrients ≥ 100%" />
        <KpiCard label="Favorites" value={14} helper="Salmon, Greek yogurt…" />
        <KpiCard label="Active sessions" value={2} helper="iPhone, iPad" />
      </div>

      {/* Tabs */}
      <div className="flex gap-0 mt-2 border-b border-[var(--color-border)] mb-6">
        {["Activity", "Profile", "Sessions (2)", "Reminders (3)", "Audit log"].map((t, i) => (
          <a
            key={t}
            href="#"
            className={
              i === 0
                ? "px-4 py-3 text-[13px] font-semibold text-[var(--color-text)] border-b-2 border-[var(--color-accent)] -mb-px"
                : "px-4 py-3 text-[13px] text-[var(--color-text-muted)] hover:text-[var(--color-text)]"
            }
          >
            {t}
          </a>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-[2fr_1fr] gap-4">
        <Card>
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-lg font-semibold tracking-tight">Recent meal logs</h3>
              <p className="text-[12px] text-[var(--color-text-muted)]">Last 7 days</p>
            </div>
            <a href="/meal-logs" className="text-[12px] text-[var(--color-text-muted)] hover:text-[var(--color-text)]">All logs →</a>
          </div>

          <table className="w-full text-[13px]">
            <thead className="border-b border-[var(--color-border)]">
              <tr>
                <th className="px-3 py-2.5 text-left text-[10px] font-bold tracking-[0.08em] uppercase text-[var(--color-text-muted)]">Date</th>
                <th className="px-3 py-2.5 text-left text-[10px] font-bold tracking-[0.08em] uppercase text-[var(--color-text-muted)]">Meal</th>
                <th className="px-3 py-2.5 text-left text-[10px] font-bold tracking-[0.08em] uppercase text-[var(--color-text-muted)]">Items</th>
                <th className="px-3 py-2.5 text-left text-[10px] font-bold tracking-[0.08em] uppercase text-[var(--color-text-muted)]">Top nutrients</th>
              </tr>
            </thead>
            <tbody>
              {[
                { d: "Apr 24", m: "Breakfast", items: "Greek yogurt, Almonds", n: ["Ca","Mg"] as const },
                { d: "Apr 24", m: "Lunch",     items: "Salmon, Spinach, Sweet potato", n: ["D","A","K"] as const },
                { d: "Apr 23", m: "Dinner",    items: "Lentils, Avocado", n: ["B9","Fe"] as const },
                { d: "Apr 23", m: "Snack",     items: "Almonds", n: ["Mg"] as const },
                { d: "Apr 22", m: "Breakfast", items: "Egg, Avocado", n: ["D","K"] as const },
              ].map((r, i) => (
                <tr key={i} className="border-b border-[var(--color-border)] last:border-0">
                  <td className="px-3 py-3">{r.d}</td>
                  <td className="px-3 py-3">{r.m}</td>
                  <td className="px-3 py-3">{r.items}</td>
                  <td className="px-3 py-3"><div className="flex gap-1">{r.n.map(c => <NutrientPill key={c} code={c} size="sm" />)}</div></td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>

        <div className="space-y-4">
          <Card>
            <h3 className="text-lg font-semibold tracking-tight mb-4">Active sessions</h3>
            <div className="space-y-3.5">
              <div className="flex items-start gap-3">
                <span className="mt-1.5 w-2 h-2 rounded-full bg-[var(--color-accent)] shrink-0" />
                <div className="flex-1 text-[13px]">
                  <strong>iPhone 15 Pro · iOS 18.2</strong>
                  <small className="block text-[var(--color-text-muted)] text-[11px] mt-0.5">Lisbon, PT · {fmtRelative(user.lastActive)}</small>
                </div>
                <Button variant="ghost" size="xs">Revoke</Button>
              </div>
              <div className="flex items-start gap-3">
                <span className="mt-1.5 w-2 h-2 rounded-full bg-[var(--color-text-muted)] shrink-0" />
                <div className="flex-1 text-[13px]">
                  <strong>iPad Air · iPadOS 17.4</strong>
                  <small className="block text-[var(--color-text-muted)] text-[11px] mt-0.5">Lisbon, PT · last seen Apr 19</small>
                </div>
                <Button variant="ghost" size="xs">Revoke</Button>
              </div>
            </div>
          </Card>

          <Card className="!border-[#F0D2D2]">
            <h3 className="text-lg font-semibold tracking-tight text-[var(--color-err)]">Danger zone</h3>
            <p className="text-[12px] text-[var(--color-text-muted)] mb-4 mt-1">All actions trigger an entry in the audit log.</p>
            <div className="flex flex-col gap-2">
              <Button variant="danger" size="sm">Force email re-verification</Button>
              <Button variant="danger" size="sm">Suspend account</Button>
              <Button variant="danger" size="sm">Delete & purge data (GDPR)</Button>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
