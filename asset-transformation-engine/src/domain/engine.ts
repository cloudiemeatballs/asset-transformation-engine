import { Assessment, ConfidenceGrade, confidenceOrder, Criterion, GateAssessment, GateStatus, KillerAssumption, OpportunityDTO, OpportunityFamilyDTO, OpportunityStage, ThesisParts, TransformationThesis } from "./types";

export function evaluateGate(score: number | null, confidence: ConfidenceGrade, threshold: number, minimumConfidence: ConfidenceGrade): GateStatus {
  if (score === null || confidence === "X") return "HOLD";
  if (score >= threshold) return confidenceOrder[confidence] >= confidenceOrder[minimumConfidence] ? "PASS" : "HOLD";
  return confidence === "A" || confidence === "B" ? "FAIL" : "HOLD";
}
export function evaluateOpportunityGates(criteria: Criterion[], assessments: Assessment[]) {
  const gates: GateAssessment[] = criteria.filter(c => c.isGate).map(c => {
    const assessment = consensusAssessment(assessments.filter(a => a.criterionCode === c.code));
    if (!assessment) return { id: `missing-${c.code}`, criterionCode: c.code, score: 0, confidence: "X", rationale: "Not yet assessed.", assessorType: "ai", assessorName: "System", evidenceSupporting: [], evidenceContradicting: [], createdAt: new Date(0).toISOString(), gateStatus: "HOLD" };
    return { ...assessment, gateStatus: evaluateGate(assessment.score, assessment.confidence, c.gateThreshold!, c.minimumConfidence!) };
  });
  const overall: GateStatus = gates.length === 0 ? "NOT_EVALUATED" : gates.some(g => g.gateStatus === "FAIL") ? "FAIL" : gates.some(g => g.gateStatus === "HOLD") ? "HOLD" : "PASS";
  return { gates, overall };
}
export function consensusAssessment(items: Assessment[]): Assessment | null {
  if (!items.length) return null;
  const humans = items.filter(a => a.assessorType === "human");
  if (humans.length === 1) return humans[0];
  if (humans.length > 1) {
    const sorted = [...humans].sort((a,b) => a.score-b.score); const middle = Math.floor(sorted.length/2);
    const score = sorted.length%2 ? sorted[middle].score : (sorted[middle-1].score+sorted[middle].score)/2;
    const confidence = humans.reduce((worst,a) => confidenceOrder[a.confidence] < confidenceOrder[worst] ? a.confidence : worst, "A" as ConfidenceGrade);
    return { ...humans[0], id: `consensus-${humans.map(h=>h.id).join("-")}`, score, confidence, assessorName: `${humans.length} reviewer consensus`, rationale: humans.map(h=>h.rationale).join(" · "), evidenceSupporting: [...new Set(humans.flatMap(h=>h.evidenceSupporting))], evidenceContradicting: [...new Set(humans.flatMap(h=>h.evidenceContradicting))] };
  }
  return [...items].sort((a,b) => b.createdAt.localeCompare(a.createdAt))[0];
}
export function reviewerDisagreement(items: Assessment[]) { const scores=items.filter(a=>a.assessorType==="human").map(a=>a.score); return { range: scores.length ? Math.max(...scores)-Math.min(...scores) : 0, high: scores.length>1 && Math.max(...scores)-Math.min(...scores)>=2 }; }
export function calculateScore(criteria: Criterion[], assessments: Assessment[], gates: GateStatus) {
  if (gates !== "PASS") return null;
  return Math.round(criteria.reduce((sum,c) => sum + ((consensusAssessment(assessments.filter(a=>a.criterionCode===c.code))?.score ?? 0)/5)*c.weight,0)*1000)/10;
}
export function buildTransformationThesis(parts: ThesisParts): TransformationThesis { const complete=Object.values(parts).every(v=>typeof v==="string"&&v.trim().length>0); return { ...parts, complete, renderedText: complete ? `${parts.mechanism} is clinically validated in ${parts.context}, but its therapeutic potential is constrained by ${parts.constraint}, which appears to result from ${parts.causalMechanism}. We propose ${parts.transformation} to alter ${parts.drugProperty}, with the goal of producing ${parts.clinicalAdvantage}.` : null }; }
export function canPromote(opportunity: OpportunityDTO, to: OpportunityStage) {
  const fatalRefuted=opportunity.assumptions.some(a=>a.criticality==="fatal"&&a.status==="refuted");
  if (to==="gated_opportunity") return result(opportunity.thesis.complete && opportunity.overallGateStatus==="PASS" && !fatalRefuted, "Complete thesis, six passing gates, and no refuted fatal assumption required.");
  if (to==="asset_opportunity") return result((opportunity.score??0)>=70 && opportunity.assumptions.length>0 && opportunity.diligenceActions.length>0 && !!opportunity.strongestSupportingArgument && !!opportunity.strongestDisconfirmingArgument, "Score ≥70, assumptions, next-best evidence, and both arguments required.");
  if (to==="lead_candidate") return result((opportunity.score??0)>=80 && score(opportunity,"human_biology_validation")>=4 && score(opportunity,"transformation_fit")>=4 && score(opportunity,"therapeutic_delta")>=4 && score(opportunity,"technical_feasibility")>=3 && !fatalRefuted && opportunity.assumptions.some(a=>a.bestTest), "Lead thresholds and a credible kill test required.");
  return result(false,"Unsupported automatic transition.");
}
const result=(allowed:boolean,reason:string)=>({allowed,reason}); const score=(o:OpportunityDTO,c:string)=>consensusAssessment(o.assessments.filter(a=>a.criterionCode===c))?.score??0;
export function independentTargetCount(family: OpportunityFamilyDTO, opportunities: OpportunityDTO[]) { const qualifying=new Set(family.members.filter(m=>m.tier==="tier_1_lead"||m.tier==="tier_2_pipeline").map(m=>opportunities.find(o=>o.id===m.opportunityId)?.target).filter(Boolean)); return qualifying.size; }
export function compileSearch(q: import("./schemas").TransformationSearchQuery) { return `FIND ${q.mechanismType ?? "therapeutic mechanisms"} WITH HUMAN VALIDATION >= ${q.minimumHumanValidation} IN ${q.indication ?? q.therapeuticArea ?? "any therapeutic area"} WHERE CURRENT MEDICINES ARE LIMITED BY ${q.constraintClass ?? "a clinically significant constraint"} TRANSFORM USING ${q.transformation ?? "a repeatable engineering strategy"} INTENDED TO ALTER ${q.drugProperty ?? "an engineerable drug property"} TO ACHIEVE ${q.clinicalAdvantage ?? "a material clinical advantage"} REQUIRE Therapeutic Delta >= ${q.minimumTherapeuticDelta}; Technical Feasibility >= ${q.minimumTechnicalFeasibility}; Independent Targets >= ${q.minimumIndependentTargets}; Lead-Quality Opportunities >= ${q.minimumLeadQualityOpportunities}. EVIDENCE STANDARD: ${q.evidenceStandard.toUpperCase()}. RANK BY ${q.rankingCriteria.join(", ")}.` }
export function fatalAssumptionForcesFailure(assumptions: KillerAssumption[]) { return assumptions.some(a=>a.criticality==="fatal"&&a.status==="refuted"); }
