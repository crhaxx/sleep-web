import {supabase,requireUser} from "./supabase.js";
export async function list(table,select="*"){const user=await requireUser();const {data,error}=await supabase.from(table).select(select).eq("user_id",user.id);if(error)throw error;return data||[]}
export async function savePlan(input){const user=await requireUser();const {data,error}=await supabase.from("sleep_plans").insert({...input,user_id:user.id}).select().single();if(error)throw error;return data}
export async function deleteOwned(table,id){const user=await requireUser();const {error}=await supabase.from(table).delete().eq("id",id).eq("user_id",user.id);if(error)throw error}
export async function saveEntry(input){const user=await requireUser();const {data,error}=await supabase.from("sleep_entries").upsert({...input,user_id:user.id},{onConflict:"user_id,sleep_date"}).select().single();if(error)throw error;return data}
export async function getProfile(){const user=await requireUser();const {data,error}=await supabase.from("profiles").select("*").eq("id",user.id).single();if(error)throw error;return data}
export async function updateProfile(input){const user=await requireUser();const {data,error}=await supabase.from("profiles").update({...input,updated_at:new Date().toISOString()}).eq("id",user.id).select().single();if(error)throw error;return data}
export async function createGroup(name,description){const {data,error}=await supabase.rpc("create_group_with_owner",{group_name:name,group_description:description||null});if(error)throw error;return data}
export async function requestDeleteAccount(){const {error}=await supabase.rpc("delete_own_account");if(error)throw error;await supabase.auth.signOut()}
