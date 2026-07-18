import{c as C,a as m,h as N}from"./BuuyhAFx.js";import{S as z,p as A,g as s,d as I,f as L,s as P,h as j,r as B,a as T,u as f,T as q}from"./DZ39TTlt.js";import{a as g,e as D,i as E,b as F}from"./DCTRt-hF.js";import{e as G}from"./B78k3Vj8.js";import{p as o,r as H}from"./Dnbfx5bd.js";/**
 * @file
 * @license @lucide/svelte v1.25.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const J={xmlns:"http://www.w3.org/2000/svg",width:24,height:24,viewBox:"0 0 24 24",fill:"none",stroke:"currentColor","stroke-width":2,"stroke-linecap":"round","stroke-linejoin":"round"};/**
 * @file
 * @license @lucide/svelte v1.25.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const K=a=>{for(const t in a)if(t.startsWith("aria-")||t==="role"||t==="title")return!0;return!1};/**
 * @file
 * @license @lucide/svelte v1.25.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const M=Symbol("lucide-context"),O=()=>z(M);var Q=N("<svg><!><!></svg>");function $(a,t){A(t,!0);const e=O()??{},k=o(t,"color",19,()=>e.color??"currentColor"),i=o(t,"size",19,()=>e.size??24),c=o(t,"strokeWidth",19,()=>e.strokeWidth??2),v=o(t,"absoluteStrokeWidth",19,()=>e.absoluteStrokeWidth??!1),b=o(t,"iconNode",19,()=>[]),l=H(t,["$$slots","$$events","$$legacy","name","color","size","strokeWidth","absoluteStrokeWidth","iconNode","children"]),W=f(()=>v()?Number(c())*24/Number(i()):c());var r=Q();g(r,n=>({...J,...n,...l,width:i(),height:i(),stroke:k(),"stroke-width":s(W),class:["lucide-icon lucide",e.class,t.name&&`lucide-${t.name}`,t.class]}),[()=>!t.children&&!K(l)&&{"aria-hidden":"true"}]);var d=I(r);D(d,17,b,E,(n,x)=>{var h=f(()=>q(s(x),2));let _=()=>s(h)[0],S=()=>s(h)[1];var u=C(),p=L(u);G(p,_,!0,(y,R)=>{g(y,()=>({...S()}))}),m(n,u)});var w=P(d);F(w,()=>t.children??j),B(r),m(a,r),T()}export{$ as I};
