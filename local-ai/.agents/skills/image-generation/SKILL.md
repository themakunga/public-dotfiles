---
name: image-generation
description: Generate a local PNG.
---
# Generate a local PNG

Run `ai-image "<prompt>" "<output.png>"` with actual arguments. Check the exit status and verify output before reporting success. Never send private data to a remote inference service or recursively launch the current agent. If the heavy-job lock is held, report the conflict and ask the user to stop the managed server or finish the current job. Do not remove locks or terminate other jobs automatically. A routing decision alone does not change the active model.
