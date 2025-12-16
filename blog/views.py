from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse
from .models import Post


def blog_list(request):
    """List all blog posts"""
    posts = Post.objects.all().order_by('-created_at')
    return JsonResponse({
        'posts': [
            {
                'id': post.id,
                'title': post.title,
                'excerpt': post.excerpt,
                'created_at': post.created_at.isoformat(),
            }
            for post in posts
        ]
    })


def blog_detail(request, pk):
    """Get a single blog post"""
    post = get_object_or_404(Post, pk=pk)
    return JsonResponse({
        'id': post.id,
        'title': post.title,
        'content': post.content,
        'excerpt': post.excerpt,
        'created_at': post.created_at.isoformat(),
        'updated_at': post.updated_at.isoformat(),
    })

