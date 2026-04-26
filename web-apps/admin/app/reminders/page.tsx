import { api } from "@/lib/api";
import { PageHeader } from "@/components/ui/PageHeader";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Chip } from "@/components/ui/Chip";
import { KpiCard } from "@/components/ui/KpiCard";
import { Table, THead, TH, TBody, TRow, TD } from "@/components/ui/Table";
import { Download, Plus } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function RemindersPage() {
  const templates = await api.listReminderTemplates();

  return (
    <div className="p-8">
      <PageHeader
        title="Reminders"
        sub="System-wide reminder templates and delivery health"
        actions={
          <>
            <Button variant="ghost" size="sm"><Download size={12} /> Export</Button>
            <Button variant="primary" size="sm"><Plus size={14} /> New template</Button>
          </>
        }
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <KpiCard label="Sent (24h)"        value={12847} delta={{ value: 3.2, up: true }} />
        <KpiCard label="Open rate"         value={38.4}  decimals={1} suffix="%" delta={{ value: 1.1, suffix: "pt", up: true }} />
        <KpiCard label="Failed delivery"   value={3}     emphasisColor="var(--color-warn)" helper="FCM errors" />
        <KpiCard label="Active templates"  value={templates.filter(t => t.active).length} helper={`${templates.filter(t => !t.active).length} paused`} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-[2fr_1fr] gap-4">
        <div>
          <div className="rounded-t-[18px] border border-b-0 border-[var(--color-border)] bg-[var(--color-surface)] p-3 flex items-center gap-2">
            <strong className="text-[13px]">Templates</strong>
            <div className="flex-1" />
            <select className="h-8 px-3 bg-white border border-[var(--color-border)] rounded-lg text-[12px]">
              <option>All triggers</option><option>Time-based</option><option>Behavior-based</option>
            </select>
          </div>

          <Table className="rounded-t-none border-t-0">
            <THead>
              <TH>Title</TH>
              <TH>Trigger</TH>
              <TH>Audience</TH>
              <TH>Sent (7d)</TH>
              <TH>Status</TH>
              <TH><span className="sr-only">Actions</span></TH>
            </THead>
            <TBody>
              {templates.map((t, i) => (
                <TRow key={t.id} index={i}>
                  <TD>
                    <strong>{t.title}</strong>
                    <div className="text-[11px] text-[var(--color-text-muted)] mt-0.5">&ldquo;{t.body}&rdquo;</div>
                  </TD>
                  <TD className="text-[var(--color-text-muted)] text-[12px]">{t.trigger}</TD>
                  <TD className="text-[var(--color-text-muted)] text-[12px]">{t.audience}</TD>
                  <TD className="tabular">{t.sent7d.toLocaleString()}</TD>
                  <TD>
                    {t.active
                      ? <Chip variant="accent" dot>Active</Chip>
                      : <Chip variant="muted"  dot>Paused</Chip>}
                  </TD>
                  <TD><a href="#" className="text-[var(--color-text-muted)] text-[12px] hover:text-[var(--color-text)]">Edit</a></TD>
                </TRow>
              ))}
            </TBody>
          </Table>
        </div>

        <div className="space-y-4">
          <Card>
            <h3 className="text-lg font-semibold tracking-tight">Delivery health</h3>
            <p className="text-[12px] text-[var(--color-text-muted)] mb-4">Last 24 hours, by platform</p>
            <div className="space-y-3.5">
              <Bar label="iOS · APNs"    pct={99.6} color="var(--color-accent)" />
              <Bar label="Android · FCM" pct={98.2} color="var(--color-accent)" />
              <Bar label="Email fallback" pct={94.1} color="var(--color-warn)" />
            </div>
          </Card>

          <Card>
            <h3 className="text-lg font-semibold tracking-tight mb-3">Recent failures</h3>
            <div className="space-y-3">
              <Failure tone="warn"  text="FCM token invalid for 3 users"  time="22 min ago" />
              <Failure tone="warn"  text="APNs 410 (gone) for 1 user"     time="1 h ago" />
              <Failure tone="muted" text="Postmark bounce: 2 emails"       time="3 h ago" />
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}

function Bar({ label, pct, color }: { label: string; pct: number; color: string }) {
  return (
    <div>
      <div className="flex items-center justify-between text-[13px]">
        <span>{label}</span>
        <strong className="tabular">{pct}%</strong>
      </div>
      <div className="h-1.5 bg-[var(--color-surface-muted)] rounded-full mt-1.5 overflow-hidden">
        <div className="h-full transition-all" style={{ width: `${pct}%`, background: color }} />
      </div>
    </div>
  );
}

function Failure({ tone, text, time }: { tone: "warn" | "muted"; text: string; time: string }) {
  const dot = tone === "warn" ? "bg-[var(--color-warn)]" : "bg-[var(--color-text-muted)]";
  return (
    <div className="flex gap-3 items-start">
      <span className={`mt-1.5 w-2 h-2 rounded-full ${dot} shrink-0`} />
      <div className="flex-1 text-[13px]">
        {text}
        <small className="block text-[var(--color-text-muted)] text-[11px] mt-0.5">{time}</small>
      </div>
    </div>
  );
}
