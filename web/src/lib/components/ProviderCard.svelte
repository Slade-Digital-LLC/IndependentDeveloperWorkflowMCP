<script lang="ts">
	import * as Card from '$lib/components/ui/card';
	import * as Alert from '$lib/components/ui/alert';
	import { Badge } from '$lib/components/ui/badge';
	import { Button } from '$lib/components/ui/button';
	import { Input } from '$lib/components/ui/input';
	import { Label } from '$lib/components/ui/label';

	type Status = 'configured' | 'not_configured' | 'unknown';

	interface Props {
		title: string;
		// Visual badge: green=configured, gray=not configured, blue for hint label
		status: Status;
		statusLabel?: string;
		// Help text (HTML allowed via {@html})
		helpHtml?: string;
		// Token input
		tokenLabel?: string;
		tokenPlaceholder?: string;
		// Optional URL input (for self-host: Ollama, Gitea, Forgejo, GitLab self-host)
		urlLabel?: string;
		urlPlaceholder?: string;
		urlValue?: string;
		// Callbacks
		onSave: (payload: { token: string; url?: string }) => Promise<void>;
		onTest?: () => Promise<{ ok: boolean; message: string }>;
	}

	let {
		title,
		status,
		statusLabel,
		helpHtml = '',
		tokenLabel = 'Token',
		tokenPlaceholder = '',
		urlLabel,
		urlPlaceholder = '',
		urlValue = $bindable(''),
		onSave,
		onTest,
	}: Props = $props();

	let token: string = $state('');
	let saving: boolean = $state(false);
	let testing: boolean = $state(false);
	let saveMessage: string | null = $state(null);
	let saveError: boolean = $state(false);
	let testMessage: string | null = $state(null);
	let testError: boolean = $state(false);

	const alertGreen = 'border-green-500/30 bg-green-500/15 text-green-600 dark:text-green-400 *:data-[slot=alert-description]:text-green-600 dark:*:data-[slot=alert-description]:text-green-400';

	const badgeConfigured = status === 'configured';
	const badgeText = statusLabel ?? (badgeConfigured ? 'Configured' : 'Not configured');

	async function handleSave() {
		if (!token.trim()) return;
		saving = true; saveMessage = null; saveError = false;
		try {
			await onSave({ token: token.trim(), url: urlValue?.trim() || undefined });
			saveMessage = 'Saved.';
			token = '';
		} catch (e) {
			saveMessage = e instanceof Error ? e.message : 'Save failed';
			saveError = true;
		}
		saving = false;
	}

	async function handleTest() {
		if (!onTest) return;
		testing = true; testMessage = null; testError = false;
		try {
			const r = await onTest();
			testMessage = r.message;
			testError = !r.ok;
		} catch (e) {
			testMessage = e instanceof Error ? e.message : 'Test failed';
			testError = true;
		}
		testing = false;
	}
</script>

<Card.Root size="sm">
	<Card.Header>
		<Card.Title class="text-base">{title}</Card.Title>
	</Card.Header>
	<Card.Content>
		<div class="mb-3">
			{#if badgeConfigured}
				<Badge variant="outline" class="border-green-500/30 bg-green-500/15 text-green-600 dark:text-green-400">{badgeText}</Badge>
			{:else}
				<Badge variant="secondary">{badgeText}</Badge>
			{/if}
		</div>

		{#if helpHtml}
			<p class="text-xs text-muted-foreground mb-3">{@html helpHtml}</p>
		{/if}

		{#if saveMessage}
			<Alert.Root variant={saveError ? 'destructive' : 'default'} class="py-2 mb-2 {saveError ? '' : alertGreen}">
				<Alert.Description class="text-xs">{saveMessage}</Alert.Description>
			</Alert.Root>
		{/if}
		{#if testMessage}
			<Alert.Root variant={testError ? 'destructive' : 'default'} class="py-2 mb-2 {testError ? '' : alertGreen}">
				<Alert.Description class="text-xs">{testMessage}</Alert.Description>
			</Alert.Root>
		{/if}

		<form onsubmit={(e) => { e.preventDefault(); handleSave(); }} class="space-y-2">
			{#if urlLabel}
				<div>
					<Label class="text-xs mb-1">{urlLabel}</Label>
					<Input type="text" bind:value={urlValue} placeholder={urlPlaceholder} disabled={saving} class="h-8" />
				</div>
			{/if}
			<div>
				<Label class="text-xs mb-1">{tokenLabel}</Label>
				<Input type="password" bind:value={token} placeholder={tokenPlaceholder} disabled={saving} class="h-8" />
			</div>
			<div class="flex gap-2">
				<Button type="submit" disabled={saving || !token.trim()} size="sm" class="flex-1">
					{saving ? 'Saving...' : 'Save'}
				</Button>
				{#if onTest}
					<Button type="button" variant="outline" onclick={handleTest} disabled={testing} size="sm" class="flex-1">
						{testing ? 'Testing...' : 'Test'}
					</Button>
				{/if}
			</div>
		</form>
	</Card.Content>
</Card.Root>
