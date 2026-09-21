# Career Experience Inventory

> Source-of-truth notes for future resume variants, interview preparation, portfolio stories, and Codex work.
>
> These experiences were intentionally compressed or omitted from previous resumes as the career shifted toward modern full-stack, cloud, distributed systems, and AI. Preserve them here so they can be selectively surfaced when relevant. Do not force all of them into every resume.

## Career thread

Mobile and field systems → physical-device integration → end-to-end product ownership and team leadership → enterprise/cloud and distributed systems → production AI/ML.

For roles involving IoT, edge systems, physical devices, field operations, or mobile/backend integration, the older experience is relevant evidence rather than a new career pivot.

## 2012–2013 — Android / food delivery

- Started career building Android food-delivery applications.
- Early native-mobile and product-development experience.
- Worked in a very lean engineering setup alongside an experienced mentor.

## 2012–2017 — Lean-team ownership and leadership

- For much of this period, operated as the primary developer alongside a mentor who also contributed technically.
- Worked across whatever the product required rather than within strict frontend/backend/DevOps boundaries.
- In 2015, brought in three interns and trained them over roughly 2–3 years.
- Progressively transferred ownership of a major project to the team before leaving in 2017.
- By 2014–2017, responsibilities included technical/project leadership, not only individual implementation.

## 2014–2017 — Apollo Tyres roadside-assistance ecosystem

- Led development of a roadside-assistance operational platform.
- Worked on the CRM and built a Yii2 bridge/backend supporting an Android application used by roadside-assistance engineers in the field.
- Built a leadership/management dashboard exposing approximately 90 operational metrics.
- Met directly with Apollo Tyres scientists who consumed the collected field data to analyze tyre performance and improve tyre quality.
- Trained the three interns over multiple years and handed over the large project before departure.

Conceptual flow:

Field engineer → Android application → Yii2/CRM integration → operational data → leadership analytics / tyre scientists → physical-product quality feedback.

## 2015 — RFID access, attendance and HR system

- Built a .NET desktop HR/attendance application integrated with RFID-based electronic door locks.
- Employee RFID scans were used for physical access and punch-in/punch-out attendance.
- Application logged attendance and supported HR workflows.
- Worked with an electrical-engineer mentor while integrating and troubleshooting the physical system.
- Physical testing could require diagnosing device state and resetting hardware.

Conceptual flow:

RFID credential → application/business logic → electronic door lock → attendance/HR state.

## 2015 — Motorola handheld inventory application

- Built an inventory-management application running on Motorola handheld devices.
- The Motorola device used separate/external barcode-scanning software; the scanner software invoked/opened the application after an item scan.
- The application consumed the scan context and helped users manage items through multiple inventory workflow stages.
- Do not claim direct barcode-scanner or firmware programming.
- Physical-device testing and hardware state/reset issues were part of integration work.

Conceptual flow:

Physical item → Motorola barcode-scanning software → application → inventory workflow/state.

## 2018 — Android ice-hockey coaching application

- Built an Android application used by coaches during ice-hockey games.
- Coaches marked shots/game events and information around attacking/defending play.
- Application supported reporting/analysis from the captured game data.
- Useful example of mobile software capturing structured data from a live physical event.

## 2019–2020 — Government HR/attendance Android application

- Started an Android HR/attendance project for a government office in India and worked on it for approximately one year before leaving the project.
- Supported employee attendance/punching.
- Added location validation requiring the user to be within approximately 200 metres of the expected location to reduce fake/remote attendance.
- Useful example of device location/geofencing being used as a business/security constraint.

Conceptual flow:

Mobile GPS/location → proximity validation → attendance action → HR record.

## 2023 — Adaptive Cruise Control university project

- Led a university team building an adaptive-cruise-control prototype.
- Worked end-to-end across MATLAB/Simulink and the physical hardware setup, including sensors, circuitry/wiring and integration.
- Led integration and troubleshooting rather than contributing only an isolated software component.
- Helped several other student teams set up and debug their hardware environments.
- Treat as an academic physical-control-system project; do not imply production automotive or firmware experience.
- Exact component/board details should be verified before adding them to a resume.

## Modern experience to combine with this inventory

The older device/mobile experience becomes most useful when paired with the recent career:

- Modern full-stack engineering across .NET/C#, React/TypeScript, Java/Spring, Node and Python.
- AWS/cloud infrastructure and infrastructure-as-code.
- Event-driven/distributed systems using technologies such as Kinesis, Pulsar, Kafka/RabbitMQ.
- Docker/Kubernetes/ArgoCD and production observability including Honeycomb/OpenTelemetry.
- Production AI/ML ownership, including Guardlane: classifier + selective LLM fallback, SageMaker deployment, services/infrastructure/observability and production rollout.
- Increasing technical-leadership scope through design decisions, PR reviews, investigations, cross-team collaboration and end-to-end project ownership.

## Resume usage guidance

Do not turn this inventory into a hardware/IoT identity that overstates the career.

Preferred positioning is an experienced software engineer with deep modern full-stack/cloud/distributed/AI experience who has repeatedly crossed the software ↔ physical-world boundary.

For a conventional senior full-stack role, keep much of the early detail compressed.

For roles like Jetson that explicitly span mobile → backend → IoT/device integration, selectively surface:
1. Apollo field/mobile/data platform and leadership.
2. RFID-controlled electronic-lock attendance system.
3. Motorola handheld inventory workflow.
4. Android experience, especially geofenced attendance and live hockey data capture.
5. 2023 physical ACC integration and team leadership.
6. Recent cloud/distributed/AI depth.

Accuracy guardrails:
- Do not claim firmware-engineering experience.
- Do not claim direct barcode-scanner control for the Motorola application.
- Do not invent remembered protocols, boards, APIs, device models, or component details.
- Keep the ACC project explicitly academic unless stronger evidence is later added.
