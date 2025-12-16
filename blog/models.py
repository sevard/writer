from django.db import models


class Post(models.Model):
    """Blog post model"""
    title = models.CharField(max_length=200)
    excerpt = models.TextField(max_length=500, blank=True)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Blog Post'
        verbose_name_plural = 'Blog Posts'

    def __str__(self):
        return self.title

