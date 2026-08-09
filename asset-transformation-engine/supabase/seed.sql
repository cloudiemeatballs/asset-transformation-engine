-- Staging/demo seed. All opportunity records are explicitly illustrative.
-- This file is idempotent: it may be safely reapplied to staging.

insert into ingestion_sources (provider, provider_type, base_url, status, configuration)
values
  ('pubmed', 'publication_index', 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils', 'active', '{"mode":"live","rateLimitPerSecond":3}'::jsonb),
  ('clinicaltrials.gov', 'clinical_trial_registry', 'https://clinicaltrials.gov/api/v2', 'planned', '{"mode":"not_connected"}'::jsonb)
on conflict (provider) do update set
  provider_type = excluded.provider_type,
  base_url = excluded.base_url,
  status = excluded.status,
  configuration = excluded.configuration,
  updated_at = now();

-- Minimal canonical parents preserve projection referential integrity. Rich scientific
-- content remains explicitly illustrative until reviewed and promoted through the SOP.
insert into therapeutic_areas (id, name, slug, description)
values ('20000000-0000-4000-8000-000000000001', 'Illustrative research', 'illustrative-research', 'Staging-only illustrative records.')
on conflict (id) do update set name=excluded.name, slug=excluded.slug, description=excluded.description;

insert into indications (id, therapeutic_area_id, name, slug, description)
values ('20000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000001', 'Multiple illustrative contexts', 'multiple-illustrative-contexts', 'Projection anchor for staging demonstrations.')
on conflict (id) do update set name=excluded.name, description=excluded.description;

insert into mechanisms (id, name, description, mechanism_type)
values ('20000000-0000-4000-8000-000000000003', 'Illustrative mechanism set', 'Projection anchor only.', 'illustrative')
on conflict (id) do update set name=excluded.name, description=excluded.description;

insert into mechanism_contexts (id, mechanism_id, indication_id, context_description)
values ('20000000-0000-4000-8000-000000000004', '20000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000002', 'Staging-only projection context.')
on conflict (id) do update set context_description=excluded.context_description, updated_at=now();

insert into constraint_types (id, code, name, description, sort_order)
values ('20000000-0000-4000-8000-000000000005', 'ILLUSTRATIVE_STAGING', 'Illustrative staging constraint', 'Projection anchor only.', 999)
on conflict (id) do update set name=excluded.name, description=excluded.description;

insert into constraints (id, mechanism_context_id, constraint_type_id, name, statement, clinical_manifestation, causal_mechanism, status, created_by_type)
values ('20000000-0000-4000-8000-000000000006', '20000000-0000-4000-8000-000000000004', '20000000-0000-4000-8000-000000000005', 'Illustrative staging constraint', 'See the labeled projection payload.', 'Illustrative only.', 'Not canonically assessed.', 'candidate', 'system_seed')
on conflict (id) do update set statement=excluded.statement, updated_at=now();

insert into transformations (id, family, name, engineering_primitive, description)
values ('20000000-0000-4000-8000-000000000007', 'illustrative', 'Illustrative transformation set', 'Multiple demo architectures', 'Projection anchor only.')
on conflict (id) do update set name=excluded.name, description=excluded.description, updated_at=now();

insert into drug_properties (id, category, code, name, description)
values ('20000000-0000-4000-8000-000000000008', 'illustrative', 'illustrative_staging_property', 'Illustrative staging property', 'Projection anchor only.')
on conflict (id) do update set name=excluded.name, description=excluded.description;

insert into opportunities (id, name, slug, mechanism_context_id, constraint_id, transformation_id, primary_drug_property_id, stage, recommendation, mandatory_thesis, mandatory_thesis_complete, overall_gate_status, current_score, current_confidence, sensitivity_low, sensitivity_high, created_by_type)
values
  ('10000000-0000-4000-8000-000000000001','TGFBR1 lung-restricted inhibition','tgfbr1-lung-delivery','20000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000008','transformation_hypothesis','hold','Illustrative staging projection; scientific review required.',true,'HOLD',null,'C',null,null,'system_seed'),
  ('10000000-0000-4000-8000-000000000002','JAK1 gut-selective delivery','jak1-gut-delivery','20000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000008','lead_candidate','advance','Illustrative staging projection; scientific review required.',true,'PASS',84,'B',79,90,'system_seed'),
  ('10000000-0000-4000-8000-000000000003','NRF2 kidney-directed activation','nrf2-kidney-delivery','20000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000008','asset_opportunity','investigate','Illustrative staging projection; scientific review required.',true,'PASS',73,'B',68,79,'system_seed'),
  ('10000000-0000-4000-8000-000000000004','Tumor-local STING agonism','sting-tumor-activation','20000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000008','asset_opportunity','advance','Illustrative staging projection; scientific review required.',true,'PASS',85,'B',80,91,'system_seed'),
  ('10000000-0000-4000-8000-000000000005','FGFR1 agonist half-life extension','fgfr1-half-life','20000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000008','transformation_hypothesis','hold','Illustrative staging projection; scientific review required.',true,'HOLD',null,'B',null,null,'system_seed'),
  ('10000000-0000-4000-8000-000000000006','LRP1 shuttle for CNS enzyme delivery','lrp1-bbb-shuttle','20000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000008','asset_opportunity','advance','Illustrative staging projection; scientific review required.',true,'PASS',89,'B',84,95,'system_seed'),
  ('10000000-0000-4000-8000-000000000007','KRAS targeted degradation','kras-degrader','20000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000008','transformation_hypothesis','hold','Illustrative staging projection; scientific review required.',true,'HOLD',null,'C',null,null,'system_seed'),
  ('10000000-0000-4000-8000-000000000008','IL-13 receptor-clustering agonist','il13-bispecific','20000000-0000-4000-8000-000000000004','20000000-0000-4000-8000-000000000006','20000000-0000-4000-8000-000000000007','20000000-0000-4000-8000-000000000008','killed','kill','Illustrative staging projection; scientific review required.',true,'FAIL',null,'B',null,null,'system_seed')
on conflict (id) do update set
  name=excluded.name, slug=excluded.slug, stage=excluded.stage, recommendation=excluded.recommendation,
  overall_gate_status=excluded.overall_gate_status, current_score=excluded.current_score,
  current_confidence=excluded.current_confidence, sensitivity_low=excluded.sensitivity_low,
  sensitivity_high=excluded.sensitivity_high, updated_at=now();

insert into opportunity_read_models (opportunity_id, slug, payload, source_version, refreshed_at)
values
  ('10000000-0000-4000-8000-000000000001', 'tgfbr1-lung-delivery', jsonb_build_object(
    'id','tgfbr1-lung-delivery','slug','tgfbr1-lung-delivery','name','TGFBR1 lung-restricted inhibition',
    'target','TGFBR1','mechanism','TGFBR1 inhibition','indication','Idiopathic pulmonary fibrosis','therapeuticArea','Fibrotic disease',
    'constraint','Systemic pathway inhibition limits sustained target coverage','constraintType','SAFETY_ON_TARGET_OFF_TISSUE',
    'transformation','Antibody–small-molecule conjugate','transformationFamily','targeted_delivery','drugProperty','cell and tissue distribution',
    'clinicalAdvantage','wider therapeutic index','stage','transformation_hypothesis','recommendation','hold',
    'overallGateStatus','HOLD','score',null,'confidence','C','sensitivityLow',null,'sensitivityHigh',null,
    'familyId','precision-delivery','familyName','Precision Delivery Foundry','familyTier','tier_3_expansion','illustrative',true
  ), 1, now()),
  ('10000000-0000-4000-8000-000000000002', 'jak1-gut-delivery', jsonb_build_object(
    'id','jak1-gut-delivery','slug','jak1-gut-delivery','name','JAK1 gut-selective delivery',
    'target','JAK1','mechanism','JAK1 inhibition','indication','Ulcerative colitis','therapeuticArea','Immunology',
    'constraint','Systemic immunosuppression constrains exposure','constraintType','DISTRIBUTION_WRONG_CELL',
    'transformation','Inflammation-targeted conjugate','transformationFamily','targeted_delivery','drugProperty','tissue distribution',
    'clinicalAdvantage','reduced toxicity','stage','lead_candidate','recommendation','advance',
    'overallGateStatus','PASS','score',84,'confidence','B','sensitivityLow',79,'sensitivityHigh',90,
    'familyId','precision-delivery','familyName','Precision Delivery Foundry','familyTier','tier_1_lead','illustrative',true
  ), 1, now()),
  ('10000000-0000-4000-8000-000000000003', 'nrf2-kidney-delivery', jsonb_build_object(
    'id','nrf2-kidney-delivery','slug','nrf2-kidney-delivery','name','NRF2 kidney-directed activation',
    'target','NFE2L2','mechanism','NRF2 activation','indication','Chronic kidney disease','therapeuticArea','Renal disease',
    'constraint','Systemic activation creates off-tissue pharmacology','constraintType','SELECTIVITY_TISSUE',
    'transformation','Kidney-targeted prodrug','transformationFamily','targeted_delivery','drugProperty','tissue distribution',
    'clinicalAdvantage','improved tissue selectivity','stage','asset_opportunity','recommendation','investigate',
    'overallGateStatus','PASS','score',73,'confidence','B','sensitivityLow',68,'sensitivityHigh',79,
    'familyId','precision-delivery','familyName','Precision Delivery Foundry','familyTier','tier_2_pipeline','illustrative',true
  ), 1, now()),
  ('10000000-0000-4000-8000-000000000004', 'sting-tumor-activation', jsonb_build_object(
    'id','sting-tumor-activation','slug','sting-tumor-activation','name','Tumor-local STING agonism',
    'target','TMEM173','mechanism','STING agonism','indication','Solid tumors','therapeuticArea','Oncology',
    'constraint','Systemic cytokine toxicity limits dose','constraintType','SAFETY_IMMUNE_TOXICITY',
    'transformation','Protease-activated therapeutic','transformationFamily','conditional_activation','drugProperty','conditional activation',
    'clinicalAdvantage','wider therapeutic index','stage','asset_opportunity','recommendation','advance',
    'overallGateStatus','PASS','score',85,'confidence','B','sensitivityLow',80,'sensitivityHigh',91,
    'familyId','precision-delivery','familyName','Precision Delivery Foundry','familyTier','tier_2_pipeline','illustrative',true
  ), 1, now()),
  ('10000000-0000-4000-8000-000000000005', 'fgfr1-half-life', jsonb_build_object(
    'id','fgfr1-half-life','slug','fgfr1-half-life','name','FGFR1 agonist half-life extension',
    'target','FGFR1','mechanism','FGFR1/β-Klotho agonism','indication','Metabolic dysfunction-associated steatohepatitis','therapeuticArea','Metabolic disease',
    'constraint','Short exposure prevents durable pharmacology','constraintType','PK_SHORT_HALF_LIFE',
    'transformation','Albumin-binding half-life module','transformationFamily','half_life_engineering','drugProperty','half life',
    'clinicalAdvantage','longer dosing interval','stage','transformation_hypothesis','recommendation','hold',
    'overallGateStatus','HOLD','score',null,'confidence','B','sensitivityLow',null,'sensitivityHigh',null,'illustrative',true
  ), 1, now()),
  ('10000000-0000-4000-8000-000000000006', 'lrp1-bbb-shuttle', jsonb_build_object(
    'id','lrp1-bbb-shuttle','slug','lrp1-bbb-shuttle','name','LRP1 shuttle for CNS enzyme delivery',
    'target','LRP1','mechanism','Lysosomal enzyme replacement','indication','Neuronopathic lysosomal storage disease','therapeuticArea','Neurology',
    'constraint','Therapeutic enzyme does not cross the blood-brain barrier','constraintType','DISTRIBUTION_CNS',
    'transformation','Receptor-mediated BBB shuttle','transformationFamily','tissue_transport','drugProperty','CNS exposure',
    'clinicalAdvantage','CNS access','stage','asset_opportunity','recommendation','advance',
    'overallGateStatus','PASS','score',89,'confidence','B','sensitivityLow',84,'sensitivityHigh',95,'illustrative',true
  ), 1, now()),
  ('10000000-0000-4000-8000-000000000007', 'kras-degrader', jsonb_build_object(
    'id','kras-degrader','slug','kras-degrader','name','KRAS targeted degradation',
    'target','KRAS','mechanism','KRAS suppression','indication','KRAS-mutant solid tumors','therapeuticArea','Oncology',
    'constraint','Incomplete pathway suppression and target recovery','constraintType','RESISTANCE_TARGET_RECOVERY',
    'transformation','Antibody–degrader conjugate','transformationFamily','protein_degradation','drugProperty','intracellular exposure',
    'clinicalAdvantage','overcome resistance','stage','transformation_hypothesis','recommendation','hold',
    'overallGateStatus','HOLD','score',null,'confidence','C','sensitivityLow',null,'sensitivityHigh',null,'illustrative',true
  ), 1, now()),
  ('10000000-0000-4000-8000-000000000008', 'il13-bispecific', jsonb_build_object(
    'id','il13-bispecific','slug','il13-bispecific','name','IL-13 receptor-clustering agonist',
    'target','IL13RA1','mechanism','IL-13 pathway modulation','indication','Atopic dermatitis','therapeuticArea','Immunology',
    'constraint','Receptor geometry limits selective signaling','constraintType','RECEPTOR_GEOMETRY',
    'transformation','Bispecific antibody','transformationFamily','multispecificity','drugProperty','receptor clustering',
    'clinicalAdvantage','higher efficacy','stage','killed','recommendation','kill',
    'overallGateStatus','FAIL','score',null,'confidence','B','sensitivityLow',null,'sensitivityHigh',null,'illustrative',true
  ), 1, now())
on conflict (opportunity_id) do update set
  slug = excluded.slug,
  payload = excluded.payload,
  source_version = excluded.source_version,
  refreshed_at = now();
