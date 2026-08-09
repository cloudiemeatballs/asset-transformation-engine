"use client";
import {useState} from "react";
import {Badge} from "@/components/domain";

const defaultQuestion="Is TGFBR1 clinically validated in idiopathic pulmonary fibrosis, and is systemic off-tissue exposure the principal constraint that lung-restricted delivery could solve?";
const tracks=[
  ["Biology validation","Human genetics, disease tissue, pathway and target-specific evidence"],
  ["Clinical translation","Trials, biomarkers, efficacy, safety and discontinuations"],
  ["Constraint causality","Evidence connecting exposure and dose intensity to failure"],
  ["Transformation feasibility","Lung targeting, payload release, tissue PK and safety separation"],
  ["Competitive landscape","Active programs, patents and adjacent modalities"],
  ["Contrary evidence","Alternative explanations and evidence that falsifies the thesis"],
] as const;
const evidence=[
  ["Biology validation","Pathway-level validation is stronger than direct target-specific clinical validation.","3 support · 1 contrary","C","hold"],
  ["Therapeutic validation","No qualifying target-specific human efficacy package is present in this prototype.","0 support","X","fail"],
  ["Constraint causality","Systemic safety is plausible, but not established as the dominant cause of failure.","2 support · 2 contrary","C","hold"],
  ["Transformation support","Lung-restricted delivery lacks matched proof of therapeutic-index separation.","1 support","D","hold"],
] as const;
const proposals=[
  {role:"Constraint identification",claim:"Systemic pathway inhibition is associated with off-tissue pharmacology that may restrict sustained target coverage.",sources:["Illustrative publication A · Results §3","Illustrative regulatory source B · Safety §2"],limit:"Association does not establish that this was the principal reason for failure."},
  {role:"Transformation support",claim:"A lung-targeted format produced higher lung-to-plasma exposure than an untargeted comparator in an illustrative model.",sources:["Illustrative preclinical study C · Figure 4"],limit:"Distribution improvement alone does not demonstrate efficacy or therapeutic-index separation."},
];

export function ThesisResearchPrototype(){
  const[question,setQuestion]=useState(defaultQuestion);const[started,setStarted]=useState(false);
  return <>
    <div className="eyebrow">Decision-oriented scientific diligence · Prototype</div>
    <div className="row-between"><div><h1>Thesis Research Agent</h1><p className="lede">Start with the decision the evidence must inform. The output is a cited dossier, not a feed of extracted sentences.</p></div><Badge tone="hold">Illustrative workflow</Badge></div>
    <section className="section research-brief"><div className="eyebrow">Research brief</div><label htmlFor="thesis-question">Decision question</label><textarea id="thesis-question" value={question} onChange={e=>setQuestion(e.target.value)} rows={4}/><div className="research-scope"><div><span>Opportunity</span><b>TGFBR1 lung-restricted inhibition</b></div><div><span>Decision</span><b>PASS / HOLD / FAIL</b></div><div><span>Evidence cutoff</span><b>Current at run time</b></div><div><span>Standard</span><b>Human approval required</b></div></div><button className="action-button" onClick={()=>setStarted(true)} disabled={!question.trim()}>{started?"Illustrative dossier generated":"Preview research dossier"}</button><p className="small">Prototype only: no AI model or external provider is called. Examples below are illustrative and are not biomedical facts.</p></section>
    {!started&&<section className="section panel empty-dossier"><div className="eyebrow">What will be produced</div><h2>A decision-ready research dossier</h2><p className="lede">Preview the sample to evaluate the structure before connecting real research providers.</p></section>}
    {started&&<div className="dossier">
      <section className="section"><div className="section-head"><h2>Research plan</h2><span className="small">6 parallel evidence tracks</span></div><div className="grid grid-3">{tracks.map(([title,objective],i)=><div className="panel research-track" key={title}><span className="track-number">0{i+1}</span><h3>{title}</h3><p className="small">{objective}</p></div>)}</div></section>
      <section className="section panel decision-summary"><div className="row-between"><div><div className="eyebrow">Provisional answer</div><h2>Keep the opportunity on HOLD</h2></div><Badge tone="hold">HOLD · Confidence C</Badge></div><p>The illustrative package does not establish target-specific human efficacy, prove systemic exposure is the dominant constraint, or demonstrate that lung-restricted delivery creates meaningful therapeutic-index separation.</p><div className="decision-columns"><div><b>What appears plausible</b><p className="small">The pathway is relevant and off-tissue exposure could limit dosing.</p></div><div><b>What is not established</b><p className="small">Causal failure mechanism, matched delivery advantage and repeatability.</p></div><div><b>What would change the decision</b><p className="small">Human validation plus matched tissue PK, efficacy and safety separation.</p></div></div></section>
      <section className="section"><div className="section-head"><h2>Evidence map</h2><span className="small">Every conclusion maps to a thesis link</span></div><table><thead><tr><th>Thesis link</th><th>Synthesized conclusion</th><th>Evidence</th><th>Confidence</th></tr></thead><tbody>{evidence.map(([role,conclusion,count,confidence,tone])=><tr key={role}><td><b>{role}</b></td><td>{conclusion}</td><td className="mono">{count}</td><td><Badge tone={tone}>{confidence}</Badge></td></tr>)}</tbody></table></section>
      <section className="section detail-grid"><div className="stack"><div className="section-head"><h2>Canonical claim proposals</h2><span className="small">Synthesized, cited, reviewable</span></div>{proposals.map(p=><article className="panel claim-proposal" key={p.claim}><div className="row-between"><Badge>{p.role}</Badge><Badge tone="hold">Needs verification</Badge></div><p className="claim-text">{p.claim}</p><div className="citation-list">{p.sources.map((s,i)=><div key={s}><span>[{i+1}]</span> {s}</div>)}</div><div className="claim-caveat"><b>Interpretation limit:</b> {p.limit}</div><div className="claim-actions"><button className="secondary-button">Inspect sources</button><button className="action-button">Send to review</button></div></article>)}</div>
      <aside className="stack"><section className="panel"><div className="eyebrow">Contrary evidence</div><h2>Alternative explanations</h2><ul className="compact-list"><li>Disease heterogeneity could explain incomplete response independently of exposure.</li><li>Broad pathway biology may make tissue restriction insufficient.</li><li>Delivery limitations may replace rather than solve the constraint.</li></ul></section><section className="panel"><div className="eyebrow">Critical gaps</div><h2>Next best evidence</h2><ol className="compact-list"><li>Find target-specific human evidence.</li><li>Establish exposure–toxicity causality.</li><li>Compare targeted and untargeted formats.</li><li>Test transfer to another payload.</li></ol></section><section className="panel excluded-evidence"><div className="eyebrow">Excluded by relevance screen</div><p>“However, when predictions fail, the consequences for patients are often catastrophic, especially in prostate cancer where nomograms influence the decision to therapeutically intervene.”</p><Badge tone="fail">No thesis link</Badge><p className="small">No relevant target, asset, constraint, transformation or causal observation.</p></section></aside></section>
      <section className="section panel audit-chain"><div className="eyebrow">Audit chain</div><div className="audit-steps"><span>Decision</span><i>→</i><span>Synthesized claim</span><i>→</i><span>Sources</span><i>→</i><span>Exact data</span><i>→</i><span>Human approval</span></div></section>
    </div>}
  </>
}
