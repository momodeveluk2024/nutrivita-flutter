import { api } from "@/lib/api";
import { PageHeader } from "@/components/ui/PageHeader";
import { Button } from "@/components/ui/Button";
import { Chip } from "@/components/ui/Chip";
import { NutrientPill } from "@/components/ui/NutrientPill";
import { Table, THead, TH, TBody, TRow, TD } from "@/components/ui/Table";
import { Plus, Download } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function NutrientsPage() {
  const nutrients = await api.listNutrients();
  const vits = nutrients.filter((n) => n.group === "vitamin");
  const mins = nutrients.filter((n) => n.group === "mineral");
  const macs = nutrients.filter((n) => n.group === "macro");

  return (
    <div className="p-8">
      <PageHeader
        title="Nutrients & DRI"
        sub={`${nutrients.length} nutrients tracked - adult DRI values from the backend`}
        actions={
          <>
            <Button variant="ghost" size="sm"><Download size={12} /> Export</Button>
            <Button variant="primary" size="sm"><Plus size={14} /> New nutrient</Button>
          </>
        }
      />

      <div className="flex flex-wrap gap-2 mb-5">
        <Chip variant="accent">All <span className="opacity-70 ml-1">{nutrients.length}</span></Chip>
        <Chip>Vitamins <span className="text-[var(--color-text-muted)] ml-1">{vits.length}</span></Chip>
        <Chip>Minerals <span className="text-[var(--color-text-muted)] ml-1">{mins.length}</span></Chip>
        <Chip>Macros <span className="text-[var(--color-text-muted)] ml-1">{macs.length}</span></Chip>
      </div>

      <Table>
        <THead>
          <TH className="w-16">Code</TH>
          <TH>Name</TH>
          <TH>Group</TH>
          <TH>Unit</TH>
          <TH>DRI (adult)</TH>
          <TH>Foods using</TH>
          <TH>Updated</TH>
          <TH><span className="sr-only">Actions</span></TH>
        </THead>
        <TBody>
          {nutrients.map((n, i) => (
            <TRow key={n.id} index={i}>
              <TD><NutrientPill code={n.code} size="sm" /></TD>
              <TD className="font-semibold">{n.name}</TD>
              <TD className="capitalize text-[var(--color-text-muted)]">{n.group}</TD>
              <TD className="text-[var(--color-text-muted)]">{n.unit}</TD>
              <TD className="tabular"><strong>{n.driAdult}</strong> <span className="text-[var(--color-text-muted)]">{n.unit}</span></TD>
              <TD className="tabular">{n.foodCount}</TD>
              <TD className="text-[var(--color-text-muted)] text-[12px]">{n.updatedAt}</TD>
              <TD><a href={`/nutrients?code=${encodeURIComponent(n.code)}`} className="text-[var(--color-text-muted)] text-[12px] hover:text-[var(--color-text)]">Focus</a></TD>
            </TRow>
          ))}
        </TBody>
      </Table>
    </div>
  );
}
