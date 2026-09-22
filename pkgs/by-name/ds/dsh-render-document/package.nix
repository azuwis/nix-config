{
  deepseek-harness,
  runCommandLocal,
}:

# `render_document` tool plugin. `node_modules` is the dsh installation's, so
# every bare import resolves to the packages the host itself runs.
runCommandLocal "dsh-render-document-${deepseek-harness.version}" { } ''
  mkdir -p $out
  cp ${./index.mjs} $out/index.mjs
  ln -s ${deepseek-harness}/libexec/dsh/node_modules $out/node_modules
''
