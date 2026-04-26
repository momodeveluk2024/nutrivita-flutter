"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { backendFetch } from "@/lib/api";

export async function saveFood(foodId: string, formData: FormData) {
  const serving = Number(formData.get("servingSizeG"));
  const verified = formData.get("verified") === "on";
  const body = {
    name: String(formData.get("name") ?? ""),
    brand: String(formData.get("brand") ?? ""),
    category: String(formData.get("category") ?? ""),
    servingSizeG: Number.isFinite(serving) && serving > 0 ? serving : undefined,
  };

  const response = await backendFetch(`/admin/foods/${foodId}`, {
    method: "PATCH",
    body: JSON.stringify(body),
  });
  if (!response.ok) {
    throw new Error("Could not save food");
  }
  if (verified) {
    const verify = await backendFetch(`/admin/foods/${foodId}/verify`, { method: "POST", body: "{}" });
    if (!verify.ok) {
      throw new Error("Could not verify food");
    }
  }
  revalidatePath("/foods");
  revalidatePath(`/foods/${foodId}`);
}

export async function deleteFood(foodId: string) {
  const response = await backendFetch(`/admin/foods/${foodId}`, { method: "DELETE" });
  if (!response.ok) {
    throw new Error("Could not delete food");
  }
  revalidatePath("/foods");
  redirect("/foods");
}
