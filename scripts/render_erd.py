"""Render the captured schema to a vector PDF. Requires reportlab."""
import json
import math
from pathlib import Path
from reportlab.lib import colors
from reportlab.lib.pagesizes import A2, landscape
from reportlab.pdfgen import canvas

ROOT=Path(__file__).resolve().parents[1]
metadata=json.loads((ROOT/'report-evidence/schema-metadata.json').read_text())
width,height=landscape(A2)
pdf=canvas.Canvas(str(ROOT/'docs/final-erd.pdf'),pagesize=(width,height))
pdf.setTitle('Sigil - Final ERD - Milestone 3')
pdf.setFont('Helvetica-Bold',22)
pdf.drawString(30,height-35,'Sigil: final entity-relationship diagram')
pdf.setFont('Helvetica',11)
pdf.drawString(30,height-55,'13 stored relations. COURSE derives its university through INSTRUCTOR. COURSE_CONTEXT is a view.')
positions={
    'UNIVERSITY':(0,0),'INSTRUCTOR':(1,0),'COURSE':(2,0),'STUDENT':(3,0),
    'MERKLE_CHECKPOINT':(0,1),'GRADE':(1,1),'ENROLLMENT':(2,1),'STUDENT_PHONE':(3,1),
    'VERIFIER':(0,2),'DISCLOSURE_PROOF':(1,2),'DISCLOSED_GRADE':(2,2),'GRADE_DRAFT':(3,2),
    'CORRECTION_REQUEST':(1,3)}
box_width=(width-150)/4
boxes={}
for name,(col,row) in positions.items():
    x=30+col*(box_width+30)
    top=height-95-row*265
    box_height=35+len(metadata[name]['columns'])*12
    boxes[name]=(x,top-box_height,box_width,box_height)

def anchor(name,other):
    x,y,w,h=boxes[name]; cx,cy=x+w/2,y+h/2
    ox,oy,ow,oh=boxes[other]; dx,dy=ox+ow/2-cx,oy+oh/2-cy
    scale=min((w/2)/abs(dx) if dx else float('inf'),(h/2)/abs(dy) if dy else float('inf'))
    return cx+dx*scale,cy+dy*scale

def edge(parent,child,card='0..N'):
    a,b=anchor(parent,child),anchor(child,parent)
    pdf.setStrokeColor(colors.HexColor('#8b98a4'));pdf.setLineWidth(1)
    pdf.line(*a,*b)
    dx,dy=b[0]-a[0],b[1]-a[1]; length=math.hypot(dx,dy);ux,uy=dx/length,dy/length
    # Crow's-foot at the many endpoint; short crossbar at the one endpoint.
    pdf.line(a[0]-uy*5,a[1]+ux*5,a[0]+uy*5,a[1]-ux*5)
    if 'N' in card:
        for offset in [-5,0,5]:
            pdf.line(b[0],b[1],b[0]-ux*13+uy*offset,b[1]-uy*13-ux*offset)
    pdf.setFillColor(colors.HexColor('#455766'));pdf.setFont('Helvetica-Bold',8)
    pdf.drawString(a[0]+ux*14+3,a[1]+uy*14+3,'1')
    pdf.drawString(b[0]-ux*35+3,b[1]-uy*35+3,card)

for parent,child,card in [
    ('UNIVERSITY','INSTRUCTOR','0..N'),('UNIVERSITY','STUDENT','0..N'),
    ('UNIVERSITY','MERKLE_CHECKPOINT','0..N'),('INSTRUCTOR','COURSE','0..N'),
    ('STUDENT','STUDENT_PHONE','0..N'),('STUDENT','ENROLLMENT','0..N'),
    ('COURSE','ENROLLMENT','0..N'),('ENROLLMENT','GRADE_DRAFT','0..1'),
    ('STUDENT','GRADE','0..N'),('COURSE','GRADE','0..N'),
    ('MERKLE_CHECKPOINT','GRADE','1..N'),('STUDENT','DISCLOSURE_PROOF','0..N'),
    ('VERIFIER','DISCLOSURE_PROOF','0..N'),('DISCLOSURE_PROOF','DISCLOSED_GRADE','1..N'),
    ('GRADE','DISCLOSED_GRADE','0..N'),('GRADE','CORRECTION_REQUEST','0..N'),
    ('INSTRUCTOR','CORRECTION_REQUEST','0..N')]:
    edge(parent,child,card)
for name,(x,y,w,h) in boxes.items():
    pdf.setFillColor(colors.white);pdf.setStrokeColor(colors.HexColor('#334b5e'))
    pdf.roundRect(x,y,w,h,4,fill=1,stroke=1)
    pdf.setFillColor(colors.HexColor('#e5eef5'));pdf.rect(x,y+h-25,w,25,fill=1,stroke=0)
    pdf.setFillColor(colors.HexColor('#102b40'));pdf.setFont('Helvetica-Bold',12)
    pdf.drawString(x+9,y+h-17,name)
    fks={fk[0] for fk in metadata[name]['foreign_keys']}
    pdf.setFont('Courier',9)
    for i,(field,kind,key,nullable) in enumerate(metadata[name]['columns']):
        tags=(' PK' if key=='PRI' else '')+(' FK' if field in fks else '')
        pdf.drawString(x+9,y+h-40-i*12,f'{field}: {kind}{tags}'+(' ?' if nullable=='YES' else ''))
pdf.setFont('Helvetica',11);pdf.setFillColor(colors.HexColor('#102b40'))
notes=['PK = primary key; FK = foreign key; ? = nullable.',
       'GRADE self-reference: a grade supersedes zero or one prior grade;',
       'each prior grade can have at most one successor.',
       'CORRECTION_REQUEST.approved_grade_id: optional, unique reference to GRADE.',
       'A valid proof and a published checkpoint each require at least one grade.',
       'See final-erd.mmd for every relationship, and final-schema.md for constraints.']
for i,line in enumerate(notes):pdf.drawString(900,220-i*18,line)
pdf.save()
print('Rendered docs/final-erd.pdf')
