"""Initial migration - Create all tables with pgvector support

Revision ID: 001
Revises: 
Create Date: 2025-02-18 14:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import pgvector.sqlalchemy

# revision identifiers, used by Alembic.
revision: str = '001'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Enable pgvector extension
    op.execute('CREATE EXTENSION IF NOT EXISTS vector')
    
    # Create users table
    op.create_table(
        'users',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('display_name', sa.String(length=100), nullable=False),
        sa.Column('avatar_url', sa.String(length=500), nullable=True),
        sa.Column('bio', sa.Text(), nullable=True),
        sa.Column('location', sa.String(length=200), nullable=True),
        sa.Column('sustainability_score', sa.Float(), nullable=False, server_default='0.0'),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('email')
    )
    op.create_index('idx_users_email', 'users', ['email'])
    op.create_index('idx_users_sustainability', 'users', ['sustainability_score'])
    
    # Create garments table
    op.create_table(
        'garments',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('owner_id', sa.UUID(), nullable=False),
        sa.Column('title', sa.String(length=200), nullable=False),
        sa.Column('category', sa.String(length=50), nullable=False),
        sa.Column('condition', sa.String(length=20), nullable=False),
        sa.Column('size', sa.String(length=20), nullable=False),
        sa.Column('brand', sa.String(length=100), nullable=True),
        sa.Column('story', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('provenance', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('exchange_type', sa.String(length=20), nullable=False),
        sa.Column('price', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('style_attributes', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('embedding', pgvector.sqlalchemy.Vector(dim=512), nullable=True),
        sa.Column('view_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('save_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('status', sa.String(length=20), nullable=False, server_default='active'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['owner_id'], ['users.id'], ondelete='CASCADE')
    )
    op.create_index('idx_garments_owner', 'garments', ['owner_id'])
    op.create_index('idx_garments_category', 'garments', ['category'])
    op.create_index('idx_garments_exchange_type', 'garments', ['exchange_type'])
    op.create_index('idx_garments_status', 'garments', ['status'])
    op.create_index('idx_garments_created', 'garments', ['created_at'])
    op.create_index('idx_garments_price', 'garments', ['price'])
    
    # Create exchanges table
    op.create_table(
        'exchanges',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('garment_id', sa.UUID(), nullable=False),
        sa.Column('buyer_id', sa.UUID(), nullable=False),
        sa.Column('seller_id', sa.UUID(), nullable=False),
        sa.Column('type', sa.String(length=20), nullable=False),
        sa.Column('status', sa.String(length=20), nullable=False, server_default='pending'),
        sa.Column('amount', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('message', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['garment_id'], ['garments.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['buyer_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['seller_id'], ['users.id'], ondelete='CASCADE')
    )
    op.create_index('idx_exchanges_garment', 'exchanges', ['garment_id'])
    op.create_index('idx_exchanges_buyer', 'exchanges', ['buyer_id'])
    op.create_index('idx_exchanges_seller', 'exchanges', ['seller_id'])
    op.create_index('idx_exchanges_status', 'exchanges', ['status'])
    op.create_index('idx_exchanges_created', 'exchanges', ['created_at'])
    
    # Create wardrobes table
    op.create_table(
        'wardrobes',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('owner_id', sa.UUID(), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('story', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('sustainability_score', sa.Float(), nullable=False, server_default='0.0'),
        sa.Column('is_public', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['owner_id'], ['users.id'], ondelete='CASCADE')
    )
    op.create_index('idx_wardrobes_owner', 'wardrobes', ['owner_id'])
    op.create_index('idx_wardrobes_public', 'wardrobes', ['is_public'])
    
    # Create wardrobe_garments association table
    op.create_table(
        'wardrobe_garments',
        sa.Column('wardrobe_id', sa.UUID(), nullable=False),
        sa.Column('garment_id', sa.UUID(), nullable=False),
        sa.Column('added_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.PrimaryKeyConstraint('wardrobe_id', 'garment_id'),
        sa.ForeignKeyConstraint(['wardrobe_id'], ['wardrobes.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['garment_id'], ['garments.id'], ondelete='CASCADE')
    )
    op.create_index('idx_wardrobe_garments_wardrobe', 'wardrobe_garments', ['wardrobe_id'])
    op.create_index('idx_wardrobe_garments_garment', 'wardrobe_garments', ['garment_id'])
    
    # Create saved_garments table (for user saves/likes)
    op.create_table(
        'saved_garments',
        sa.Column('user_id', sa.UUID(), nullable=False),
        sa.Column('garment_id', sa.UUID(), nullable=False),
        sa.Column('saved_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('user_id', 'garment_id'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['garment_id'], ['garments.id'], ondelete='CASCADE')
    )
    op.create_index('idx_saved_garments_user', 'saved_garments', ['user_id'])
    op.create_index('idx_saved_garments_garment', 'saved_garments', ['garment_id'])


def downgrade() -> None:
    op.drop_table('saved_garments')
    op.drop_table('wardrobe_garments')
    op.drop_table('wardrobes')
    op.drop_table('exchanges')
    op.drop_table('garments')
    op.drop_table('users')
    op.execute('DROP EXTENSION IF EXISTS vector')
