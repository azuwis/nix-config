import { Service } from '@deepseek-ai/cordis'

export const name = 'dsh-plugin-install-test'

export function apply() {
  console.log('[dsh-plugin-install-test] loaded with cordis ' + typeof Service)
}
