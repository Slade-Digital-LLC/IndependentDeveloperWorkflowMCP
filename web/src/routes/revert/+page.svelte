<script lang="ts">
	import { onMount } from 'svelte';
	import { selectedRepo } from '$lib/stores';
	import { fetchRevertPreview, type RevertPreview } from '$lib/api';
	import * as Card from '$lib/components/ui/card';
	import * as Alert from '$lib/components/ui/alert';
	import TriangleAlertIcon from '@lucide/svelte/icons/triangle-alert';

	let preview = $state<RevertPreview | null>(null);
	let error = $state<string | null>(null);

	async function load() {
		try {
			error = null;
			preview = await fetchRevertPreview();
		} catch (e) {
			error = e instanceof Error ? e.message : 'Failed to load revert preview';
		}
	}

	onMount(() => {
		load();
		const unsub = selectedRepo.subscribe(() => { load(); });
		return unsub;
	});

	let totalActions = $derived(
		preview ? preview.repos.reduce((sum: number, r) => sum + r.triage_results + r.pr_analyses + r.labels_to_remove, 0) : 0
	);
</script>

<svelte:head>
	<title>wshm - Revert</title>
</svelte:head>

<div class="mb-6">
	<h2 class="text-xl font-bold tracking-tight mb-1">Revert Actions</h2>
	<p class="text-sm text-muted-foreground">Preview and undo all wshm-applied labels, comments, and analyses</p>
</div>

{#if error}
	<Alert.Root variant="destructive">
		<Alert.Description>{error}</Alert.Description>
	</Alert.Root>
{:else if preview}
	<Alert.Root class="mb-6 border-yellow-500/40 bg-yellow-500/10 text-yellow-700 dark:text-yellow-200 [&>svg]:text-yellow-500">
		<TriangleAlertIcon />
		<Alert.Title>Destructive Operation</Alert.Title>
		<Alert.Description class="text-xs text-yellow-700/90 dark:text-yellow-200/90">
			Reverting will remove all wshm comments, labels, triage results, and PR analyses from GitHub.
			This cannot be undone. Use <code class="bg-yellow-500/20 px-1.5 py-0.5 rounded">wshm revert --apply</code> from the CLI to execute.
		</Alert.Description>
	</Alert.Root>

	{#if totalActions === 0}
		<Card.Root class="border-green-500/40 text-center">
			<Card.Content class="p-10">
				<svg class="h-10 w-10 mx-auto mb-2 text-green-500" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
					<path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
				</svg>
				<p class="text-green-600 dark:text-green-400 font-semibold">Nothing to revert</p>
				<p class="text-xs text-muted-foreground mt-1">No wshm actions found in the database</p>
			</Card.Content>
		</Card.Root>
	{:else}
		<div class="space-y-4">
			{#each preview.repos as repo}
				<Card.Root>
					<Card.Header>
						<Card.Title class="text-sm">{repo.repo}</Card.Title>
					</Card.Header>
					<Card.Content>
						<div class="grid grid-cols-3 gap-4">
							<Card.Root class="bg-background py-4 text-center">
								<Card.Content class="px-4">
									<div class="text-2xl font-bold text-orange-600 dark:text-orange-400">{repo.triage_results}</div>
									<div class="text-xs text-muted-foreground mt-1">Triage Results</div>
									<div class="text-[0.625rem] text-muted-foreground">Comments + classifications</div>
								</Card.Content>
							</Card.Root>
							<Card.Root class="bg-background py-4 text-center">
								<Card.Content class="px-4">
									<div class="text-2xl font-bold text-orange-600 dark:text-orange-400">{repo.pr_analyses}</div>
									<div class="text-xs text-muted-foreground mt-1">PR Analyses</div>
									<div class="text-[0.625rem] text-muted-foreground">Risk + type + summary</div>
								</Card.Content>
							</Card.Root>
							<Card.Root class="bg-background py-4 text-center">
								<Card.Content class="px-4">
									<div class="text-2xl font-bold text-orange-600 dark:text-orange-400">{repo.labels_to_remove}</div>
									<div class="text-xs text-muted-foreground mt-1">Labels</div>
									<div class="text-[0.625rem] text-muted-foreground">wshm-applied labels</div>
								</Card.Content>
							</Card.Root>
						</div>
					</Card.Content>
				</Card.Root>
			{/each}
		</div>

		<Card.Root class="mt-6">
			<Card.Content>
				<p class="text-sm text-muted-foreground mb-2">
					To revert all actions, run from the CLI:
				</p>
				<code class="block bg-muted/40 px-4 py-3 rounded text-xs text-foreground/90 font-mono">
					wshm revert --apply
				</code>
				<p class="text-xs text-muted-foreground mt-3">
					Dry-run first with <code class="bg-muted px-1.5 py-0.5 rounded">wshm revert</code> (no --apply) to see what would happen.
				</p>
			</Card.Content>
		</Card.Root>
	{/if}
{:else}
	<div class="text-center py-10 text-muted-foreground">Loading...</div>
{/if}
