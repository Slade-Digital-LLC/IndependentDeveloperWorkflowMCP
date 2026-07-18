<script lang="ts">
	import { onMount } from 'svelte';
	import { fetchBackups, createBackup, restoreBackup, type BackupsResult } from '$lib/api';
	import * as Table from '$lib/components/ui/table';

	let result = $state<BackupsResult | null>(null);
	let error = $state<string | null>(null);
	let creating = $state(false);
	let restoring = $state<string | null>(null);
	let message = $state<string | null>(null);
	let confirmingRestore = $state<string | null>(null);
	let confirmTimer: ReturnType<typeof setTimeout> | null = null;

	async function load() {
		try {
			error = null;
			result = await fetchBackups();
		} catch (e) {
			error = e instanceof Error ? e.message : 'Failed to load backups';
		}
	}

	async function handleCreate() {
		creating = true;
		message = null;
		try {
			const res = await createBackup();
			message = res.message;
			await load();
		} catch (e) {
			error = e instanceof Error ? e.message : 'Backup failed';
		}
		creating = false;
	}

	async function handleRestore(name: string) {
		// Two-step confirmation: first click arms the button (red "Confirm
		// restore"), second click within 5s actually runs. Auto-disarms.
		if (confirmingRestore !== name) {
			confirmingRestore = name;
			if (confirmTimer) clearTimeout(confirmTimer);
			confirmTimer = setTimeout(() => (confirmingRestore = null), 5000);
			return;
		}
		if (confirmTimer) clearTimeout(confirmTimer);
		confirmingRestore = null;
		restoring = name;
		message = null;
		try {
			const res = await restoreBackup(name);
			message = res.message;
		} catch (e) {
			error = e instanceof Error ? e.message : 'Restore failed';
		}
		restoring = null;
	}

	function formatSize(bytes: number): string {
		if (bytes > 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
		return (bytes / 1024).toFixed(1) + ' KB';
	}

	onMount(load);
</script>

<svelte:head>
	<title>wshm - Backups</title>
</svelte:head>

<div class="mb-6 flex items-center justify-between">
	<div>
		<h2 class="text-xl font-semibold text-foreground mb-1">Backups</h2>
		<p class="text-sm text-muted-foreground">Backup and restore your wshm database</p>
	</div>
	<button
		onclick={handleCreate}
		disabled={creating}
		class="bg-primary hover:bg-primary/90 disabled:opacity-50 text-primary-foreground text-sm font-semibold px-5 py-2.5 rounded-lg transition"
	>
		{creating ? 'Creating...' : 'Create backup'}
	</button>
</div>

{#if message}
	<div class="rounded-lg border border-green-500/40 bg-green-500/15 p-4 mb-6">
		<p class="text-sm text-green-600 dark:text-green-400">{message}</p>
	</div>
{/if}

{#if error}
	<div class="rounded-lg border border-red-500 bg-card p-5 mb-6">
		<p class="text-red-600 dark:text-red-400">{error}</p>
	</div>
{/if}

{#if result && result.backups.length > 0}
	<div class="rounded-lg border">
		<Table.Root>
			<Table.Header>
				<Table.Row>
					<Table.Head>Backup</Table.Head>
					<Table.Head>Size</Table.Head>
					<Table.Head>Date</Table.Head>
					<Table.Head>Actions</Table.Head>
				</Table.Row>
			</Table.Header>
			<Table.Body>
				{#each result.backups as b}
					<Table.Row>
						<Table.Cell class="font-mono text-sm">{b.name}</Table.Cell>
						<Table.Cell class="text-muted-foreground">{formatSize(b.size)}</Table.Cell>
						<Table.Cell class="text-xs text-muted-foreground">{b.created_at?.slice(0, 19).replace('T', ' ') ?? ''}</Table.Cell>
						<Table.Cell>
							<button
								onclick={() => handleRestore(b.name)}
								disabled={restoring === b.name}
								class="text-xs px-3 py-1.5 rounded-lg transition border {confirmingRestore === b.name ? 'border-red-500 bg-red-500/15 text-red-600 dark:text-red-400 hover:bg-red-500/25' : 'border-border text-foreground/90 hover:text-foreground hover:border-muted-foreground'}"
							>
								{#if restoring === b.name}
									Restoring...
								{:else if confirmingRestore === b.name}
									Confirm restore
								{:else}
									Restore
								{/if}
							</button>
						</Table.Cell>
					</Table.Row>
				{/each}
			</Table.Body>
		</Table.Root>
	</div>
{:else if result}
	<div class="rounded-lg border bg-card p-10 text-center">
		<svg class="h-10 w-10 mx-auto mb-2 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
			<path stroke-linecap="round" stroke-linejoin="round" d="m20.25 7.5-.625 10.632a2.25 2.25 0 0 1-2.247 2.118H6.622a2.25 2.25 0 0 1-2.247-2.118L3.75 7.5m8.25 3v6.75m0 0-3-3m3 3 3-3M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125Z" />
		</svg>
		<p class="text-muted-foreground">No backups yet.</p>
		<p class="text-xs text-muted-foreground mt-2">Click "Create backup" to save your database, config, and credentials.</p>
	</div>
{:else}
	<div class="text-center py-10 text-muted-foreground">Loading...</div>
{/if}

<div class="mt-6 rounded-lg border bg-card p-5">
	<p class="text-sm text-muted-foreground mb-2">CLI usage:</p>
	<code class="block bg-muted/40 px-4 py-2 rounded text-xs text-foreground/90 font-mono mb-1">wshm backup</code>
	<code class="block bg-muted/40 px-4 py-2 rounded text-xs text-foreground/90 font-mono">wshm restore .wshm/backup-2026-04-09.tar.gz --force</code>
</div>
