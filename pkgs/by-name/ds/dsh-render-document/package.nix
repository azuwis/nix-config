{
  deepseek-harness,
  runCommandLocal,
}:

# `render_document` tool plugin. `node_modules` points at the dsh installation,
# so every bare import resolves to the packages the host runs.
runCommandLocal "dsh-render-document-${deepseek-harness.version}" { } ''
  mkdir -p $out
  cp -r ${./src}/. $out/
  ln -s ${deepseek-harness}/libexec/dsh/node_modules $out/node_modules
''
