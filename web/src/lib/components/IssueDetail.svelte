<script lang="ts">
	import * as Card from '$lib/components/ui/card';
	import { Badge } from '$lib/components/ui/badge';
	import type { Issue } from '$lib/api';
	import Markdown from './Markdown.svelte';

	let { issue }: { issue: Issue } = $props();

	function ageDays(dateStr: string): number {
		return Math.floor((Date.now() - new Date(dateStr).getTime()) / 86400000);
	}

	const badgeGreen = 'border-green-500/30 bg-green-500/15 text-green-600 dark:text-green-400';
	const badgeRed = 'border-red-500/30 bg-red-500/15 text-red-600 dark:text-red-400';

	// `issue.url` is built server-side from the configured forge
	// (GitHub / GitLab / Gitea / Forgejo / Azure DevOps), so we never
	// need to guess the URL shape from `repo`. Older daemons that
	// didn't yet include the field — we just hide the link.
	let issueUrl = $derived(issue.url ?? null);
</script>

{#if issueUrl}
	<div class="mb-3 flex items-center gap-2 text-xs">
		<a
			href={issueUrl}
			target="_blank"
			rel="noopener noreferrer"
			class="inline-flex items-center gap-1.5 text-primary hover:text-primary/80 underline"
		>
			<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4" aria-hidden="true">
				<path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
				<polyline points="15 3 21 3 21 9" />
				<line x1="10" y1="14" x2="21" y2="3" />
			</svg>
			<span class="truncate">{issueUrl}</span>
		</a>
	</div>
{/if}

<div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
	<Card.Root class="py-3">
		<Card.Content class="px-3">
			<div class="text-[0.625rem] uppercase text-muted-foreground mb-1">State</div>
			<Badge variant="outline" class={issue.state === 'open' ? badgeGreen : badgeRed}>{issue.state}</Badge>
		</Card.Content>
	</Card.Root>
	<Card.Root class="py-3">
		<Card.Content class="px-3">
			<div class="text-[0.625rem] uppercase text-muted-foreground mb-1">Priority</div>
			<span class="text-foreground">{issue.priority ?? '-'}</span>
		</Card.Content>
	</Card.Root>
	<Card.Root class="py-3">
		<Card.Content class="px-3">
			<div class="text-[0.625rem] uppercase text-muted-foreground mb-1">Category</div>
			<span class="text-foreground">{issue.category ?? '-'}</span>
		</Card.Content>
	</Card.Root>
	<Card.Root class="py-3">
		<Card.Content class="px-3">
			<div class="text-[0.625rem] uppercase text-muted-foreground mb-1">Age</div>
			<span class="mono text-foreground">{ageDays(issue.created_at)}d</span>
		</Card.Content>
	</Card.Root>
</div>

{#if issue.labels.length > 0}
	<Card.Root class="py-3 mb-4">
		<Card.Content class="px-3">
			<div class="text-[0.625rem] uppercase text-muted-foreground mb-2">Labels</div>
			<div class="flex flex-wrap gap-1">
				{#each issue.labels as label}
					<Badge variant="outline" class="bg-primary/15 text-primary">{label}</Badge>
				{/each}
			</div>
		</Card.Content>
	</Card.Root>
{/if}

<Card.Root class="py-3 mb-4">
	<Card.Content class="px-3">
		<div class="text-[0.625rem] uppercase text-muted-foreground mb-2">Details</div>
		<div class="grid grid-cols-2 gap-2 text-sm">
			<div><span class="text-muted-foreground">Author:</span> <span class="text-foreground/90">{issue.author ?? '-'}</span></div>
			<div><span class="text-muted-foreground">Created:</span> <span class="text-foreground/90 mono">{issue.created_at?.slice(0, 10)}</span></div>
			<div><span class="text-muted-foreground">Updated:</span> <span class="text-foreground/90 mono">{issue.updated_at?.slice(0, 10)}</span></div>
		</div>
	</Card.Content>
</Card.Root>

{#if issue.body}
	<Card.Root class="py-3">
		<Card.Content class="px-3">
			<div class="text-[0.625rem] uppercase text-muted-foreground mb-2">Body</div>
			<Markdown source={issue.body} />
		</Card.Content>
	</Card.Root>
{/if}
