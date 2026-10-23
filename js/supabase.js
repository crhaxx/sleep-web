const config=window.SLEEPWISE_CONFIG||{};const url=config.supabaseUrl||"";const key=config.supabasePublishableKey||"";
export const supabase=url&&key?await import("https://esm.sh/@supabase/supabase-js@2").then(({createClient})=>createClient(url,key,{auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}})):null;
export const supabaseConfigured=Boolean(supabase);
export async function requireUser(){if(!supabase)throw new Error("Supabase is not configured. Add the public URL and publishable key in js/config.js.");const {data:{user},error}=await supabase.auth.getUser();if(error||!user)throw new Error("Please log in to continue.");return user}
