// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
//import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import {createClient} from 'npm:@supabase/supabase-js@2'
import {JWT} from 'npm:google-auth-library@9'
interface Message{
  id:string
  user_id:string
  message:string
  created_at:Date
}
const supabase=createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)



interface WebhookPayload{
  type:'Insert'
  table:string
  record:Message
  schema:'public'
  old_record:null | Message
}




Deno.serve(async (req) => {
  const payload: WebhookPayload=await req.json()
const { data:senderData } = await supabase
  .from('profiles')
  .select('username')
  .eq('id', payload.record.user_id)
  .single()
  const {data :recipientData} = await  supabase.from('profiles').select('fcm_token').neq('id',payload.record.user_id).single()
  const fcmToken=recipientData.fcm_token as string

  const {default: serviceAccount}=await
   import('../service_account.json',{
    with:{
      type:'json',
    },
  })


  const accessToken=await getAccessToken({
    clientEmail:serviceAccount.client_email,
    privateKey:serviceAccount.private_key
  })

  const senderUsername = senderData.username 
  const res=await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,

    {
      method:'POST',
      headers:{
        'Content-Type':'application/json',
        Authorization: `Bearer ${accessToken}`,

      },
      body:JSON.stringify({
        message:{
          token: fcmToken,
          notification:{
            title:`New Message from ${senderUsername}`,
            body:`You received a new message`,
          }
        }
      })
    }
  );

const resData=await res.json()
if(res.status<200||299<res.status){
  throw resData
  
}

  return new Response(
    JSON.stringify(resData),
    { headers: { 'Content-Type': 'application/json' } },
  )
})

const getAccessToken=({
  clientEmail,
  privateKey,
}:{
  clientEmail:string
  privateKey:string
}):Promise<string>=>{
  
  return new Promise((resolve,reject)=>{
    const jwtClient=new JWT({
      email:clientEmail,
      key:privateKey,
      scopes:['https://www.googleapis.com/auth/firebase.messaging']

    })
    jwtClient.authorize((err,tokens)=>{
      if(err){
        reject(err)
        return;
      }
      resolve(tokens!.access_token!)
    })
  })
}
