# Section 020: CUE For Dashboards

CUE is a configuration language where a schema and a value are written the same way. You combine your dashboard with the schemas of the Perses plugins, and CUE either completes it or tells you exactly which field breaks which rule. That makes CUE a good fit for dashboards: many of them, sharing the same panels, checked before they reach the server.

This section teaches the parts of CUE that dashboards need, the builders the Perses CUE software development kit (SDK) provides, and how to share panels between dashboards without copying them.

## What you will learn

- CUE values, types, constraints, defaults and unification, and why a definition rejects fields it does not declare.
- CUE modules and packages, and how a dashboard imports the Perses SDK and your own shared code.
- The Perses CUE builders for dashboards, panel groups and label values variables.
- Shared panel definitions with a parameter, and how CUE reports a value that breaks a plugin's schema.

## The learning path

The module has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The landing page starts the module's playground, where the dashboard `prometheus-overview` is already applied from CUE.

### 1. Write Dashboards In CUE

1. CUE Essentials For Dashboards
2. The Perses CUE Builders
3. Shared Definitions And Build-Time Validation, followed by the lab **Compose A Dashboard From Shared Panels**
4. Summary

## Section capstone: Repair A CUE Dashboard Library

A change to the shared panel library broke every CUE dashboard in the repository, and two dashboards have faults of their own. The capstone asks you to read the build errors, fix the library and the dashboards without weakening any schema, and put every dashboard on the server. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-020/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-108-capstone-020
```
